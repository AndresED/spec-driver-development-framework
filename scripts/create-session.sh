#!/bin/bash

# create-session.sh - Script para crear sesión desde template

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
    echo "Crea una nueva sesión a partir de los templates."
    echo ""
    echo "Argumentos:"
    echo "  module    Nombre del módulo (ej: users, products, orders)"
    echo "  feature   Nombre de la feature (ej: create-user, update-product)"
    echo ""
    echo "Prerrequisitos:"
    echo "  - La SPEC debe existir en docs/specs/<module>/<feature>/"
    echo "  - La SPEC debe estar completa y aprobada"
    echo ""
    echo "Ejemplo:"
    echo "  $0 users create-user"
    echo ""
    echo "Este script crea:"
    echo "  - ai-agent-rules/sessions/<module>/<feature>/session_state.md"
    echo "  - ai-agent-rules/sessions/<module>/<feature>/spec_ref.md"
    echo "  - ai-agent-rules/sessions/<module>/<feature>/instruction-pack.md"
    echo "  - ai-agent-rules/sessions/<module>/<feature>/notes.md"
    echo "  - ai-agent-rules/sessions/<module>/<feature>/status.md"
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
SESSION_DIR="ai-agent-rules/sessions/${MODULE}/${FEATURE}"
SPEC_DIR="docs/specs/${MODULE}/${FEATURE}"
TEMPLATES_DIR="ai-agent-rules/sessions/templates"

# Validar que la SPEC exista
if [ ! -d "$SPEC_DIR" ]; then
    echo -e "${RED}Error: SPEC no encontrada: $SPEC_DIR${NC}"
    echo ""
    echo "Primero crea la SPEC con:"
    echo "  ./scripts/create-spec.sh $MODULE $FEATURE"
    exit 1
fi

# Validar que la SPEC esté completa
echo -e "${YELLOW}Validando completitud de la SPEC...${NC}"

REQUIRED_SPEC_FILES=(
    "README.md"
    "domain.md"
    "use-cases.md"
    "architecture.md"
    "persistence.md"
    "testing.md"
)

for file in "${REQUIRED_SPEC_FILES[@]}"; do
    if [ ! -f "$SPEC_DIR/$file" ]; then
        echo -e "${RED}Error: Archivo de SPEC faltante: $SPEC_DIR/$file${NC}"
        exit 1
    fi
done

# Validar que los templates existan
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo -e "${RED}Error: Directorio de templates no encontrado: $TEMPLATES_DIR${NC}"
    exit 1
fi

# Validar que la sesión no exista
if [ -d "$SESSION_DIR" ]; then
    echo -e "${RED}Error: La sesión ya existe: $SESSION_DIR${NC}"
    echo ""
    echo "Si necesitas recrearla, primero elimina el directorio existente:"
    echo "  rm -rf $SESSION_DIR"
    exit 1
fi

# Crear directorio de sesión
echo -e "${YELLOW}Creando directorio de sesión: $SESSION_DIR${NC}"
mkdir -p "$SESSION_DIR"

# Lista de templates y archivos de salida
declare -A FILES=(
    ["session_state.template.md"]="$SESSION_DIR/session_state.md"
    ["spec_ref.template.md"]="$SESSION_DIR/spec_ref.md"
    ["instruction-pack.template.md"]="$SESSION_DIR/instruction-pack.md"
    ["notes.template.md"]="$SESSION_DIR/notes.md"
    ["status.template.md"]="$SESSION_DIR/status.md"
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
    sed -e "s/<module>/$MODULE/g" \
        -e "s/<feature>/$FEATURE/g" \
        "$template_file" > "$output_file"
done

# Personalizar instruction-pack.md basado en el contenido de la SPEC
echo -e "${YELLOW}Personalizando instruction-pack.md basado en la SPEC...${NC}"

# Extraer información de la SPEC para personalizar el instruction-pack
README_SPEC="$SPEC_DIR/README.md"
DOMAIN_SPEC="$SPEC_DIR/domain.md"
USE_CASES_SPEC="$SPEC_DIR/use-cases.md"

# Extraer entidad principal del domain.md
ENTITY_NAME=$(grep -A 5 "### \[.*Entidad" "$DOMAIN_SPEC" | head -1 | sed 's/### \[\(.*\)Entidad.*/\1/' | tr -d '[:space:]')

if [ -z "$ENTITY_NAME" ]; then
    ENTITY_NAME=$(echo "$FEATURE" | sed 's/-//g' | sed 's/\b\w/\u&/g')
fi

# Extraer casos de uso del use-cases.md
USE_CASES=$(grep -o "CU-[0-9][0-9]*: [^[:space:]]*" "$USE_CASES_SPEC" | head -3 | tr '\n' ', ' | sed 's/,$//')

# Personalizar instruction-pack.md
sed -i.bak \
    -e "s/<module>/$MODULE/g" \
    -e "s/<feature>/$FEATURE/g" \
    -e "s/Implementar completamente <feature>/Implementar completamente $FEATURE según SPEC/" \
    -e "s/1. Crear la estructura del módulo siguiendo Clean Architecture/1. Analizar la SPEC en $SPEC_DIR/" \
    -e "s/2. Implementar la entidad de dominio/2. Implementar $ENTITY_NAME según domain.md/" \
    "$SESSION_DIR/instruction-pack.md"

rm "$SESSION_DIR/instruction-pack.md.bak"

# Crear archivo de resumen de la sesión
SESSION_SUMMARY="$SESSION_DIR/session_summary.md"
cat > "$SESSION_SUMMARY" << EOF
# Session Summary

## Metadata
- **Module**: $MODULE
- **Feature**: $FEATURE
- **Created**: $(date '+%Y-%m-%d %H:%M:%S')
- **SPEC Path**: $SPEC_DIR
- **Session Path**: $SESSION_DIR

## SPEC Files
- [README.md](../../../../../docs/specs/$MODULE/$FEATURE/README.md)
- [domain.md](../../../../../docs/specs/$MODULE/$FEATURE/domain.md)
- [use-cases.md](../../../../../docs/specs/$MODULE/$FEATURE/use-cases.md)
- [architecture.md](../../../../../docs/specs/$MODULE/$FEATURE/architecture.md)
- [persistence.md](../../../../../docs/specs/$MODULE/$FEATURE/persistence.md)
- [testing.md](../../../../../docs/specs/$MODULE/$FEATURE/testing.md)

## Session Files
- [session_state.md](session_state.md)
- [spec_ref.md](spec_ref.md)
- [instruction-pack.md](instruction-pack.md)
- [notes.md](notes.md)
- [status.md](status.md)

## Next Steps
1. Review and complete instruction-pack.md
2. Execute agent with the instruction pack
3. Monitor implementation progress
4. Validate results against criteria
5. Update status.md when complete

## Agent Command
\`\`\`bash
cat ai-agent-rules/sessions/$MODULE/$FEATURE/instruction-pack.md | agente-ia
\`\`\`
EOF

# Mensaje de éxito
echo ""
echo -e "${GREEN}✅ Sesión creada exitosamente!${NC}"
echo ""
echo -e "${YELLOW}Siguiente pasos:${NC}"
echo "1. Revisa y personaliza: $SESSION_DIR/instruction-pack.md"
echo "2. Ejecuta el agente con:"
echo "   cat $SESSION_DIR/instruction-pack.md | agente-ia"
echo "3. Monitorea el progreso de la implementación"
echo "4. Valida los resultados contra los criterios de éxito"
echo ""
echo -e "${YELLOW}Archivos creados:${NC}"
find "$SESSION_DIR" -name "*.md" | sort
echo ""
echo -e "${YELLOW}SPEC referenciada:${NC}"
find "$SPEC_DIR" -name "*.md" | sort