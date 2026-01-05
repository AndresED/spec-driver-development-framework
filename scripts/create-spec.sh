#!/bin/bash

# create-spec.sh - Script para crear SPEC desde template

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función de ayuda
show_help() {
    echo "Uso: $0 <module> <feature>"
    echo ""
    echo "Crea una nueva SPEC a partir de los templates."
    echo ""
    echo "Argumentos:"
    echo "  module    Nombre del módulo (ej: users, products, orders)"
    echo "  feature   Nombre de la feature (ej: create-user, update-product)"
    echo ""
    echo "Ejemplo:"
    echo "  $0 users create-user"
    echo ""
    echo "Este script crea:"
    echo "  - docs/specs/<module>/<feature>/README.md"
    echo "  - docs/specs/<module>/<feature>/domain.md"
    echo "  - docs/specs/<module>/<feature>/use-cases.md"
    echo "  - docs/specs/<module>/<feature>/architecture.md"
    echo "  - docs/specs/<module>/<feature>/persistence.md"
    echo "  - docs/specs/<module>/<feature>/testing.md"
}

# Validar argumentos
if [ $# -ne 2 ]; then
    echo -e "${RED}Error: Se requieren exactamente 2 argumentos${NC}"
    echo ""
    show_help
    exit 1
fi

MODULE=$1
FEATURE=$2
SPEC_DIR="docs/specs/${MODULE}/${FEATURE}"
TEMPLATES_DIR="docs/specs/templates"

# Validar que los templates existan
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo -e "${RED}Error: Directorio de templates no encontrado: $TEMPLATES_DIR${NC}"
    exit 1
fi

# Crear directorio de SPEC
echo -e "${YELLOW}Creando directorio de SPEC: $SPEC_DIR${NC}"
mkdir -p "$SPEC_DIR"

# Lista de templates y archivos de salida
declare -A FILES=(
    ["feature.template.md"]="$SPEC_DIR/README.md"
    ["domain.template.md"]="$SPEC_DIR/domain.md"
    ["use-cases.template.md"]="$SPEC_DIR/use-cases.md"
    ["architecture.template.md"]="$SPEC_DIR/architecture.md"
    ["persistence.template.md"]="$SPEC_DIR/persistence.md"
    ["testing.template.md"]="$SPEC_DIR/testing.md"
)

# Copiar y procesar cada template
for template in "${!FILES[@]}"; do
    template_file="$TEMPLATES_DIR/$template"
    output_file="${FILES[$template]}"
    
    if [ ! -f "$template_file" ]; then
        echo -e "${RED}Error: Template no encontrado: $template_file${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Procesando: $template -> $output_file${NC}"
    
    # Reemplazar placeholders y copiar
    sed -e "s/\[module\]/$MODULE/g" \
        -e "s/\[Module\]/$(echo $MODULE | sed 's/\b\w/\u&/g')/g" \
        -e "s/\[feature\]/$FEATURE/g" \
        -e "s/\[Feature\]/$(echo $FEATURE | sed 's/-/ /g; s/\b\w/\u&/g')/g" \
        -e "s/\[EntityName\]/$(echo $FEATURE | sed 's/-//g; s/\b\w/\u&/g')/g" \
        -e "s/\[table_name\]/${MODULE}_$(echo $FEATURE | tr '-' '_')/g" \
        "$template_file" > "$output_file"
done

# Crear archivo de índice si no existe
INDEX_FILE="docs/specs/README.md"
if [ ! -f "$INDEX_FILE" ]; then
    echo -e "${YELLOW}Creando índice de SPECs: $INDEX_FILE${NC}"
    cat > "$INDEX_FILE" << EOF
# SPECs - Especificaciones del Proyecto

Este directorio contiene todas las especificaciones del proyecto.

## Estructura

Cada SPEC tiene la siguiente estructura:

- **README.md**: Visión general y requisitos
- **domain.md**: Modelo de dominio y reglas de negocio
- **use-cases.md**: Casos de uso y flujos
- **architecture.md**: Arquitectura y patrones
- **persistence.md**: Estrategia de persistencia
- **testing.md**: Estrategia de pruebas

## SPECs Existentes

EOF
fi

# Agregar la nueva SPEC al índice
echo -e "${YELLOW}Actualizando índice de SPECs${NC}"

# Verificar si el módulo ya existe en el índice
if ! grep -q "## $MODULE" "$INDEX_FILE"; then
    echo "" >> "$INDEX_FILE"
    echo "## $MODULE" >> "$INDEX_FILE"
    echo "" >> "$INDEX_FILE"
fi

# Agregar la feature al módulo correspondiente
if ! grep -q "$FEATURE" "$INDEX_FILE"; then
    echo "- [$FEATURE](specs/$MODULE/$FEATURE/README.md)" >> "$INDEX_FILE"
fi

# Mensaje de éxito
echo ""
echo -e "${GREEN}✅ SPEC creada exitosamente!${NC}"
echo ""
echo -e "${YELLOW}Siguiente pasos:${NC}"
echo "1. Editar los archivos en: $SPEC_DIR"
echo "2. Completar los placeholders [ ]"
echo "3. Validar la SPEC con stakeholders"
echo "4. Crear una sesión: ./scripts/create-session.sh $MODULE $FEATURE"
echo ""
echo -e "${YELLOW}Archivos creados:${NC}"
find "$SPEC_DIR" -name "*.md" | sort