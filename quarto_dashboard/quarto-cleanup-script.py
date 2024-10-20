import os
import signal
import subprocess
import sys

def find_quarto_processes():
    if sys.platform.startswith('win'):
        output = subprocess.check_output('tasklist /FI "IMAGENAME eq quarto.exe"', shell=True).decode()
        processes = [line.split()[1] for line in output.splitlines()[3:] if line.strip()]
    else:
        output = subprocess.check_output(['ps', 'aux']).decode()
        processes = [line.split()[1] for line in output.splitlines() if 'quarto' in line]
    return processes

def kill_processes(pids):
    for pid in pids:
        try:
            if sys.platform.startswith('win'):
                subprocess.call(['taskkill', '/F', '/PID', pid])
            else:
                os.kill(int(pid), signal.SIGKILL)
            print(f"Proceso {pid} terminado.")
        except Exception as e:
            print(f"No se pudo terminar el proceso {pid}: {e}")

def main():
    print("Buscando procesos de Quarto...")
    quarto_processes = find_quarto_processes()
    
    if quarto_processes:
        print(f"Se encontraron {len(quarto_processes)} procesos de Quarto.")
        kill_processes(quarto_processes)
    else:
        print("No se encontraron procesos de Quarto en ejecución.")

    print("Iniciando tu dashboard de Quarto...")
    # Añade aquí el comando para iniciar tu dashboard
    # Por ejemplo: subprocess.call(['quarto', 'preview', 'tu_archivo.qmd'])

if __name__ == "__main__":
    main()
