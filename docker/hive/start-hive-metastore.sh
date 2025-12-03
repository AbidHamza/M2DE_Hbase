#!/bin/bash
# Script to start Hive Metastore with proper environment setup

# Set HIVE_HOME first (before sourcing hive-env.sh)
export HIVE_HOME=${HIVE_HOME:-/opt/hive}

# Source hive-env.sh to set JAVA_HOME and HADOOP_HOME
if [ -f "${HIVE_HOME}/conf/hive-env.sh" ]; then
    source ${HIVE_HOME}/conf/hive-env.sh
fi

# Gérer le répertoire metastore_db (peut exister mais être corrompu)
METASTORE_DB_DIR="/opt/hive/metastore_db"
METASTORE_DB_PARENT="/opt/hive"
HIVE_SITE_XML="${HIVE_HOME}/conf/hive-site.xml"

echo "Vérification du répertoire metastore_db..."

# Vérifier si le répertoire existe et s'il contient une base Derby valide
if [ -d "$METASTORE_DB_DIR" ]; then
    # Vérifier si c'est une base Derby valide (doit contenir service.properties)
    if [ ! -f "$METASTORE_DB_DIR/service.properties" ]; then
        echo "WARNING: Répertoire metastore_db existe mais n'est pas une base Derby valide"
        echo "Nettoyage du contenu du répertoire corrompu (volume Docker, on ne peut pas supprimer le répertoire)..."
        # Vider le contenu du répertoire (pas le répertoire lui-même car c'est un volume Docker)
        find "$METASTORE_DB_DIR" -mindepth 1 -delete 2>/dev/null || {
            # Si find échoue, essayer rm sur les fichiers individuels
            rm -f "$METASTORE_DB_DIR"/* "$METASTORE_DB_DIR"/.* 2>/dev/null || true
        }
        echo "Contenu du répertoire vidé, sera recréé lors de l'initialisation"
    else
        echo "Base Derby valide détectée (service.properties trouvé)"
    fi
else
    echo "Répertoire metastore_db n'existe pas, sera créé lors de l'initialisation"
fi

# Créer le répertoire parent s'il n'existe pas (pour éviter les erreurs)
mkdir -p "$METASTORE_DB_PARENT"

# Verify JAVA_HOME is set
if [ -z "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
    echo "ERROR: JAVA_HOME is not set or invalid: $JAVA_HOME" >&2
    exit 1
fi

# Verify HADOOP_HOME exists and has binaries
if [ ! -d "$HADOOP_HOME" ] || [ ! -f "$HADOOP_HOME/bin/hadoop" ]; then
    echo "ERROR: HADOOP_HOME does not exist or Hadoop binaries not found: $HADOOP_HOME" >&2
    echo "ERROR: Hive requires Hadoop binaries to function" >&2
    exit 1
fi

# Verify HADOOP_CONF_DIR exists
if [ ! -d "$HADOOP_CONF_DIR" ]; then
    echo "ERROR: HADOOP_CONF_DIR does not exist: $HADOOP_CONF_DIR" >&2
    echo "ERROR: Hive cannot connect to Hadoop without configuration files" >&2
    exit 1
fi

# Verify hadoop command is available
if ! command -v hadoop >/dev/null 2>&1; then
    echo "ERROR: 'hadoop' command not found in PATH" >&2
    echo "ERROR: PATH=$PATH" >&2
    exit 1
fi

echo "Starting Hive Metastore..."
echo "JAVA_HOME: $JAVA_HOME"
echo "HADOOP_HOME: $HADOOP_HOME"
echo "HADOOP_CONF_DIR: $HADOOP_CONF_DIR"
echo "HIVE_HOME: $HIVE_HOME"
echo "HIVE_CONF_DIR: $HIVE_CONF_DIR"
echo "PATH: $PATH"
echo "Hadoop version: $(hadoop version 2>&1 | head -1 || echo 'unknown')"

# Verify hive command exists
if [ ! -f "${HIVE_HOME}/bin/hive" ]; then
    echo "ERROR: Hive binary not found at ${HIVE_HOME}/bin/hive" >&2
    exit 1
fi

# Create log directory if it doesn't exist
mkdir -p ${HIVE_HOME}/logs

# Initialiser le schéma Derby si nécessaire (vérifier si service.properties existe)
echo "Vérification de l'initialisation du schéma Derby..."
SCHEMA_INIT_ATTEMPTS=0
MAX_SCHEMA_INIT_ATTEMPTS=3

# Vérifier si la base est déjà initialisée
if [ -f "$METASTORE_DB_DIR/service.properties" ]; then
    echo "Schéma Derby déjà initialisé (service.properties trouvé)"
else
    # La base n'existe pas ou est corrompue, on doit l'initialiser
    # Modifier temporairement hive-site.xml pour utiliser create=true
    echo "Modification temporaire de hive-site.xml pour permettre la création de la base..."
    if [ -f "$HIVE_SITE_XML" ]; then
        # Sauvegarder l'original
        cp "$HIVE_SITE_XML" "$HIVE_SITE_XML.bak"
        # Modifier create=false en create=true temporairement (compatible Linux et macOS)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' 's/;create=false/;create=true/g' "$HIVE_SITE_XML"
        else
            # Linux
            sed -i 's/;create=false/;create=true/g' "$HIVE_SITE_XML"
        fi
        # Vérifier que la modification a fonctionné
        if ! grep -q ";create=true" "$HIVE_SITE_XML" 2>/dev/null; then
            echo "WARNING: Impossible de modifier hive-site.xml, restauration de l'original..." >&2
            mv "$HIVE_SITE_XML.bak" "$HIVE_SITE_XML"
        fi
    else
        echo "ERROR: hive-site.xml not found at $HIVE_SITE_XML" >&2
        exit 1
    fi
    
    while [ $SCHEMA_INIT_ATTEMPTS -lt $MAX_SCHEMA_INIT_ATTEMPTS ]; do
        SCHEMA_INIT_ATTEMPTS=$((SCHEMA_INIT_ATTEMPTS + 1))
        echo "Tentative d'initialisation du schéma Derby (tentative $SCHEMA_INIT_ATTEMPTS/$MAX_SCHEMA_INIT_ATTEMPTS)..."
        
        # Vérifier si le répertoire existe mais est vide ou corrompu
        if [ -d "$METASTORE_DB_DIR" ] && [ ! -f "$METASTORE_DB_DIR/service.properties" ]; then
            echo "Nettoyage du contenu du répertoire avant initialisation..."
            find "$METASTORE_DB_DIR" -mindepth 1 -delete 2>/dev/null || {
                rm -rf "$METASTORE_DB_DIR"/* 2>/dev/null || true
                find "$METASTORE_DB_DIR" -mindepth 1 -name ".*" -delete 2>/dev/null || true
            }
            sleep 2
        fi
        
        # Initialiser le schéma
        ${HIVE_HOME}/bin/schematool -initSchema -dbType derby 2>&1 | tee ${HIVE_HOME}/logs/schema-init.log
        SCHEMA_INIT_EXIT_CODE=${PIPESTATUS[0]}
        
        if [ $SCHEMA_INIT_EXIT_CODE -eq 0 ]; then
            echo "Schéma Derby initialisé avec succès"
            break
        else
            # Vérifier si l'erreur est "Directory already exists" ou "Database not found"
            if grep -qiE "(Directory.*already exists|XBM0J|metastore_db.*already exists|Database.*not found)" ${HIVE_HOME}/logs/schema-init.log 2>/dev/null; then
                echo "WARNING: Erreur de base de données détectée" >&2
                echo "Nettoyage du contenu du répertoire et nouvelle tentative..." >&2
                find "$METASTORE_DB_DIR" -mindepth 1 -delete 2>/dev/null || {
                    rm -rf "$METASTORE_DB_DIR"/* 2>/dev/null || true
                    find "$METASTORE_DB_DIR" -mindepth 1 -name ".*" -delete 2>/dev/null || true
                }
                sleep 3
                # Continuer la boucle pour réessayer
            else
                echo "ERROR: Échec de l'initialisation du schéma (code: $SCHEMA_INIT_EXIT_CODE)" >&2
                echo "Consultez les logs: ${HIVE_HOME}/logs/schema-init.log" >&2
                if [ $SCHEMA_INIT_ATTEMPTS -ge $MAX_SCHEMA_INIT_ATTEMPTS ]; then
                    echo "ERROR: Impossible d'initialiser le schéma Derby après $MAX_SCHEMA_INIT_ATTEMPTS tentatives" >&2
                    # Restaurer l'original avant de quitter
                    if [ -f "$HIVE_SITE_XML.bak" ]; then
                        mv "$HIVE_SITE_XML.bak" "$HIVE_SITE_XML"
                    fi
                    exit 1
                fi
            fi
        fi
    done
    
    # Restaurer hive-site.xml avec create=false après initialisation réussie
    if [ -f "$HIVE_SITE_XML.bak" ]; then
        echo "Restauration de hive-site.xml avec create=false..."
        mv "$HIVE_SITE_XML.bak" "$HIVE_SITE_XML"
    fi
fi

# Vérification finale
if [ ! -f "$METASTORE_DB_DIR/service.properties" ]; then
    echo "ERROR: Le schéma Derby n'a pas pu être initialisé" >&2
    echo "Consultez les logs: ${HIVE_HOME}/logs/schema-init.log" >&2
    exit 1
fi

# Start Hive Metastore in background and capture output
echo "Launching Hive Metastore service..."
LOG_FILE=${HIVE_HOME}/logs/metastore.log
${HIVE_HOME}/bin/hive --service metastore > "$LOG_FILE" 2>&1 &
METASTORE_PID=$!

# Function to check if Metastore is truly ready (not just port open, but responding)
check_metastore_ready() {
    # Method 1: Check process is running (must be first)
    if ! kill -0 $METASTORE_PID 2>/dev/null; then
        return 1
    fi
    
    # Method 2: Check port is listening AND accepting connections
    PORT_OPEN=0
    if command -v nc >/dev/null 2>&1; then
        if nc -z localhost 9083 2>/dev/null; then
            PORT_OPEN=1
        fi
    elif command -v timeout >/dev/null 2>&1 && command -v bash >/dev/null 2>&1; then
        if timeout 1 bash -c "echo > /dev/tcp/localhost/9083" 2>/dev/null; then
            PORT_OPEN=1
        fi
    fi
    
    if [ $PORT_OPEN -eq 0 ]; then
        return 1
    fi
    
    # Method 3: Check logs for successful startup (look for "Starting Hive Metastore Server" or similar)
    if [ -f "$LOG_FILE" ]; then
        if grep -qiE "(Starting.*Metastore|Metastore.*started|listening on|bind.*9083|ThriftBinary.*started)" "$LOG_FILE" 2>/dev/null; then
            # Check for errors in logs - if found, consider not ready
            if grep -qiE "(ERROR|FATAL|Exception.*failed|Cannot.*start|bind.*failed|Connection refused)" "$LOG_FILE" 2>/dev/null; then
                return 1
            fi
            return 0
        fi
    fi
    
    # If process is running and port is open but no startup message yet, wait a bit more
    return 1
}

# Wait for Metastore to be truly ready
echo "Waiting for Hive Metastore to be ready..."
MAX_WAIT=180
WAIT_COUNT=0
READY=0

while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    # Check if process died
    if ! kill -0 $METASTORE_PID 2>/dev/null; then
        echo "ERROR: Hive Metastore process died unexpectedly" >&2
        if [ -f "$LOG_FILE" ]; then
            echo "Last 50 lines of log:" >&2
            tail -50 "$LOG_FILE" >&2
        fi
        wait $METASTORE_PID 2>/dev/null
        exit 1
    fi
    
    # Check if ready
    if check_metastore_ready; then
        echo "Hive Metastore is ready and listening on port 9083"
        READY=1
        break
    fi
    
    sleep 3
    WAIT_COUNT=$((WAIT_COUNT + 3))
    
    # Show progress every 15 seconds
    if [ $((WAIT_COUNT % 15)) -eq 0 ]; then
        echo "Still waiting for Hive Metastore... ($WAIT_COUNT/$MAX_WAIT seconds)"
    fi
done

if [ $READY -eq 0 ]; then
    echo "ERROR: Hive Metastore did not become ready within $MAX_WAIT seconds" >&2
    if [ -f "$LOG_FILE" ]; then
        echo "Last 100 lines of log:" >&2
        tail -100 "$LOG_FILE" >&2
    fi
    kill $METASTORE_PID 2>/dev/null
    exit 1
fi

echo "Hive Metastore started successfully. PID: $METASTORE_PID"
echo "Logs available at: $LOG_FILE"

# Keep the process running and monitor it
while kill -0 $METASTORE_PID 2>/dev/null; do
    sleep 5
done

# Process exited, check exit code
wait $METASTORE_PID
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: Hive Metastore exited with code $EXIT_CODE" >&2
    if [ -f "$LOG_FILE" ]; then
        echo "Last 100 lines of log:" >&2
        tail -100 "$LOG_FILE" >&2
    fi
    exit $EXIT_CODE
fi

