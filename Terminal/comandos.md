# Comandos para copiar y pegar

Práctica: Compartir archivos de Ubuntu a Windows con Samba.
La primera parte se hace en el Ubuntu (servidor) y la segunda en el Windows (cliente).

## Parte 1. En Ubuntu (servidor)

### 1. Instalar Samba

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install samba -y
```

### 2. Crear la carpeta que se va a compartir

```bash
sudo mkdir -p /srv/samba/mi_carpeta
sudo chmod -R 0755 /srv/samba/mi_carpeta
sudo chown -R $USER:$USER /srv/samba/mi_carpeta
```

### 3. Agregar el recurso a smb.conf

```bash
sudo nano /etc/samba/smb.conf
```

Al final del archivo se pega este bloque (cambiar `eduardo` por tu usuario):

```ini
[mi_carpeta]
   path = /srv/samba/mi_carpeta
   browsable = yes
   read only = no
   valid users = eduardo
   create mask = 0664
   directory mask = 0775
```

### 4. Validar la configuración

```bash
sudo testparm
```

### 5. Crear la contraseña SMB del usuario

```bash
sudo smbpasswd -a eduardo
```

### 6. Reiniciar y revisar el servicio

```bash
sudo systemctl restart smbd
sudo systemctl status smbd
```

### 7. Sacar la IP y revisar el firewall

```bash
hostname -I
whoami
sudo ufw status
```

## Parte 2. En Windows (cliente)

Con la IP del servidor (por ejemplo 192.168.20.217):

### Opción A: Explorador de archivos

En la barra de direcciones escribir:

```
\\192.168.20.217\mi_carpeta
```

Cuando pida credenciales, usar el usuario de Samba (`eduardo`) y la contraseña SMB.

### Opción B: Símbolo del sistema (cmd)

```
ping 192.168.20.217
net use Z: \\192.168.20.217\mi_carpeta /user:eduardo
dir Z:\
```

## Alternativa: hacerlo con los scripts (en Ubuntu)

```bash
cd Codigo
chmod +x *.sh
sudo ./configurar_samba_windows.sh
./verificar_samba.sh
```
