#!/bin/bash
# ------------------------------------------------------------------
# configurar_samba_windows.sh
# Deja un Ubuntu listo para compartir una carpeta con equipos Windows
# usando Samba.
# Uso: sudo ./configurar_samba_windows.sh
# ------------------------------------------------------------------

set -e   # si un comando falla, el script se detiene

# Se necesita sudo porque se instalan paquetes y se edita /etc
if [ "$EUID" -ne 0 ]; then
    echo "Error: ejecuta el script con sudo."
    exit 1
fi

USUARIO="${SUDO_USER:-$USER}"        # usuario real que llamo a sudo
NOMBRE="mi_carpeta"                  # nombre del recurso que vera Windows
CARPETA="/srv/samba/$NOMBRE"         # carpeta del servidor que se comparte
CONF="/etc/samba/smb.conf"

echo "[1/7] Actualizando e instalando Samba..."
apt update
apt install -y samba smbclient

echo "[2/7] Creando la carpeta $CARPETA ..."
mkdir -p "$CARPETA"
chown -R "$USUARIO":"$USUARIO" "$CARPETA"   # el usuario puede escribir desde Windows
chmod -R 0755 "$CARPETA"

echo "[3/7] Agregando el recurso [$NOMBRE] a $CONF ..."
cp "$CONF" "$CONF.bak"                      # respaldo por si algo sale mal
if grep -q "^\[$NOMBRE\]" "$CONF"; then
    echo "     El recurso ya existe, no se vuelve a agregar."
else
    cat >> "$CONF" <<EOT

[$NOMBRE]
   path = $CARPETA
   browsable = yes
   read only = no
   valid users = $USUARIO
   create mask = 0664
   directory mask = 0775
EOT
fi

echo "[4/7] Validando la configuracion con testparm..."
testparm -s > /dev/null

echo "[5/7] Registrando a $USUARIO en Samba (pedira la contrasena SMB)..."
smbpasswd -a "$USUARIO"

echo "[6/7] Reiniciando y habilitando smbd..."
systemctl restart smbd
systemctl enable smbd

echo "[7/7] Revisando el firewall..."
# Si ufw esta activo se abre Samba; si esta inactivo no hace falta nada
if command -v ufw > /dev/null && ufw status | grep -q "Status: active"; then
    ufw allow samba
else
    echo "     ufw esta inactivo, no se bloquea el trafico."
fi

IP=$(hostname -I | awk '{print $1}')
echo
echo "Listo. Desde Windows abre el Explorador y escribe:"
echo "    \\\\$IP\\$NOMBRE"
echo "Usuario: $USUARIO (con la contrasena SMB que acabas de crear)"
