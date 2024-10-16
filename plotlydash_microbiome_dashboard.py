import dash
from dash import dcc, html, Input, Output
import plotly.express as px
import plotly.graph_objs as go
import pandas as pd
import numpy as np
from biom import load_table
from skbio.diversity import alpha_diversity, beta_diversity
from skbio.stats.ordination import pcoa

# Load data
biom_table = load_table("Data/Kraken/Kraken.biom")
metadata = pd.read_csv("Data/Gut/metadata.txt", sep="\t", index_col="SampleID")

# Process data
abundance_df = pd.DataFrame(biom_table.to_dataframe().transpose())
taxonomy = pd.DataFrame([t['taxonomy'] for t in biom_table.metadata(axis='observation')], index=biom_table.ids(axis='observation'))
taxonomy.columns = ['Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species']
taxonomy = taxonomy.apply(lambda x: x.str[3:])

app = dash.Dash(__name__)

app.layout = html.Div([
    html.H1("CAMDA2024 - Microbiome Dashboard"),
    
    dcc.Tabs([
        dcc.Tab(label="Read Counts", children=[
            html.Div([
                dcc.Slider(id="num-samples", min=5, max=50, step=1, value=20,
                           marks={i: str(i) for i in range(5, 51, 5)},
                           tooltip={"placement": "bottom", "always_visible": True}),
                dcc.Graph(id="read-counts-plot")
            ])
        ]),
        
        dcc.Tab(label="Abundance", children=[
            html.Div([
                dcc.Slider(id="top-taxa", min=5, max=20, step=1, value=10,
                           marks={i: str(i) for i in range(5, 21, 5)},
                           tooltip={"placement": "bottom", "always_visible": True}),
                dcc.Graph(id="abundance-plot")
            ])
        ]),
        
        dcc.Tab(label="Alpha Diversity", children=[
            html.Div([
                dcc.Checklist(
                    id="alpha-measures",
                    options=[
                        {'label': 'Observed', 'value': 'observed_features'},
                        {'label': 'Shannon', 'value': 'shannon'},
                        {'label': 'Simpson', 'value': 'simpson'},
                        {'label': 'Chao1', 'value': 'chao1'}
                    ],
                    value=['observed_features', 'shannon']
                ),
                dcc.Graph(id="alpha-diversity-plot")
            ])
        ]),
        
        dcc.Tab(label="Beta Diversity", children=[
            html.Div([
                dcc.RadioItems(
                    id="beta-transform",
                    options=[
                        {'label': 'None', 'value': 'none'},
                        {'label': 'Percentage', 'value': 'percentage'},
                        {'label': 'Log', 'value': 'log'},
                        {'label': 'Square root', 'value': 'sqrt'}
                    ],
                    value='none'
                ),
                dcc.Graph(id="beta-diversity-plot")
            ])
        ])
    ])
])

@app.callback(
    Output("read-counts-plot", "figure"),
    Input("num-samples", "value")
)
def update_read_counts(num_samples):
    reads = abundance_df.sum()
    reads = reads.sort_values(ascending=False)
    selected_samples = list(reads.index[:num_samples])
    selected_reads = reads[selected_samples]
    
    fig = px.bar(x=selected_samples, y=selected_reads / 1e6, 
                 labels={'x': 'Samples', 'y': 'Million reads'},
                 title="Total readings of analyzed samples of Shotgun")
    return fig

@app.callback(
    Output("abundance-plot", "figure"),
    Input("top-taxa", "value")
)
def update_abundance(top_taxa):
    top_species = abundance_df.sum().nlargest(top_taxa).index
    top_abundance = abundance_df[top_species].melt(var_name='Species', value_name='Abundance', ignore_index=False)
    top_abundance['Diagnosis'] = metadata.loc[top_abundance.index, 'Diagnosis']
    
    fig = px.bar(top_abundance, x='Diagnosis', y='Abundance', color='Species',
                 title="Absolute abundance", labels={'Abundance': 'Absolute abundance'})
    return fig

@app.callback(
    Output("alpha-diversity-plot", "figure"),
    Input("alpha-measures", "value")
)
def update_alpha_diversity(measures):
    alpha_div = pd.DataFrame({measure: alpha_diversity(metric=measure, counts=abundance_df.T) 
                              for measure in measures})
    alpha_div['Diagnosis'] = metadata.loc[alpha_div.index, 'Diagnosis']
    alpha_div_long = alpha_div.melt(id_vars=['Diagnosis'], var_name='Measure', value_name='Value')
    
    fig = px.box(alpha_div_long, x='Diagnosis', y='Value', color='Measure',
                 title="Alpha Diversity Indices", labels={'Value': 'Alpha Diversity Measures'})
    return fig

@app.callback(
    Output("beta-diversity-plot", "figure"),
    Input("beta-transform", "value")
)
def update_beta_diversity(transform):
    if transform == 'percentage':
        data = abundance_df.div(abundance_df.sum(axis=1), axis=0)
    elif transform == 'log':
        data = np.log1p(abundance_df)
    elif transform == 'sqrt':
        data = np.sqrt(abundance_df)
    else:
        data = abundance_df
    
    beta_div = beta_diversity('braycurtis', data.T)
    pcoa_results = pcoa(beta_div)
    
    pc1 = pcoa_results.samples['PC1']
    pc2 = pcoa_results.samples['PC2']
    
    beta_df = pd.DataFrame({'PC1': pc1, 'PC2': pc2, 'Diagnosis': metadata.loc[pc1.index, 'Diagnosis']})
    
    fig = px.scatter(beta_df, x='PC1', y='PC2', color='Diagnosis',
                     title="Beta diversity (PCoA Bray-Curtis)")
    return fig

if __name__ == '__main__':
    app.run_server(debug=True)
