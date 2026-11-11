#!/bin/bash
# ------------------------------------------------------------------
# verificar_samba.sh
# Comprueba en el servidor Ubuntu que todo este listo para que
# Windows se conecte.
# Uso: ./verificar_samba.sh [IP_DE_WINDOWS]
# Ejemplo: ./verificar_samba.sh 192.168.20.50
# ------------------------------------------------------------------

echo "=== 1. Usuario e IP del servidor ==="
whoami
hostname -I

echo
echo "=== 2. Estado del servicio smbd ==="
# --no-pager evita que systemctl se quede esperando con "(END)"
sudo systemctl status smbd --no-pager

echo
echo "=== 3. Validacion de smb.conf ==="
# -s muestra la configuracion sin pedir Enter
sudo testparm -s

echo
echo "=== 4. Puertos de Samba en escucha (139 y 445) ==="
sudo ss -tlnp | grep -E ':139|:445'

echo
echo "=== 5. Firewall ==="
sudo ufw status

# Si se paso la IP del equipo Windows, se prueba la conexion de red
if [ -n "$1" ]; then
    echo
    echo "=== 6. Ping a Windows ($1) ==="
    ping -c 4 "$1"
fi
