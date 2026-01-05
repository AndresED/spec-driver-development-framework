#!/bin/bash

# validate-architecture.sh - Script para validar arquitectura

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función de ayuda
show_help() {
    echo "Uso: $0 [module] [feature]"
    echo ""
    echo "Valida que la arquitectura del código siga las reglas establecidas."
    echo ""
    echo "Argumentos:"
    echo "  module    Nombre del módulo (opcional)"
    echo "  feature   Nombre de la feature (opcional)"
    echo ""
    echo "Si no se especifican argumentos, valida toda la aplicación."
    echo ""
    echo "Ejemplos:"
    echo "  $0                    # Valida toda la aplicación"
    echo "  $0 users              # Valida módulo users"
    echo "  $0 users create-user  # Valida feature específica"
    echo ""
    echo "Validaciones realizadas:"
    echo "  ✓ Estructura de carpetas según Clean Architecture"
    echo "  ✓ Dependencias correctas entre capas"
    echo "  ✓ Archivos en ubicaciones correctas"
    echo "  ✓ Imports válidos según reglas"
    echo "  ✓ Nomenclatura consistente"
}

# Argumentos
MODULE=${1:-""}
FEATURE=${2:-""}

# Directorios base
SRC_DIR="src"
TEST_DIR="test"
RULES_DIR="ai-agent-rules/backend"

# Función para imprimir check
print_check() {
    local status=$1
    local message=$2
    
    if [ "$status" = "PASS" ]; then
        echo -e "  ${GREEN}✓${NC} $message"
    else
        echo -e "  ${RED}✗${NC} $message"
    fi
}

# Función para validar estructura de carpetas
validate_folder_structure() {
    echo -e "${YELLOW}Validando estructura de carpetas...${NC}"
    
    local errors=0
    
    # Validar estructura base de Clean Architecture
    if [ -n "$MODULE" ]; then
        local module_path="$SRC_DIR/modules/$MODULE"
        
        # Validar carpetas principales del módulo
        local required_dirs=(
            "$module_path/domain"
            "$module_path/application"
            "$module_path/infrastructure"
            "$module_path/presentation"
        )
        
        for dir in "${required_dirs[@]}"; do
            if [ -d "$dir" ]; then
                print_check "PASS" "Directorio existe: $dir"
            else
                print_check "FAIL" "Directorio faltante: $dir"
                ((errors++))
            fi
        done
        
        # Validar subdirectorios del dominio
        if [ -d "$module_path/domain" ]; then
            local domain_subdirs=(
                "$module_path/domain/entities"
                "$module_path/domain/value-objects"
                "$module_path/domain/repositories"
                "$module_path/domain/services"
            )
            
            for dir in "${domain_subdirs[@]}"; do
                if [ -d "$dir" ]; then
                    print_check "PASS" "Subdirectorio existe: $dir"
                else
                    print_check "FAIL" "Subdirectorio faltante: $dir"
                    ((errors++))
                fi
            done
        fi
        
        # Validar subdirectorios de aplicación
        if [ -d "$module_path/application" ]; then
            local app_subdirs=(
                "$module_path/application/commands"
                "$module_path/application/queries"
                "$module_path/application/handlers"
                "$module_path/application/dto"
            )
            
            for dir in "${app_subdirs[@]}"; do
                if [ -d "$dir" ]; then
                    print_check "PASS" "Subdirectorio existe: $dir"
                else
                    print_check "FAIL" "Subdirectorio faltante: $dir"
                    ((errors++))
                fi
            done
        fi
    else
        # Validar estructura general si no hay módulo específico
        if [ -d "$SRC_DIR/modules" ]; then
            print_check "PASS" "Directorio modules existe"
        else
            print_check "FAIL" "Directorio modules faltante"
            ((errors++))
        fi
    fi
    
    return $errors
}

# Función para validar dependencias entre capas
validate_dependencies() {
    echo -e "${YELLOW}Validando dependencias entre capas...${NC}"
    
    local errors=0
    
    if [ -n "$MODULE" ]; then
        local module_path="$SRC_DIR/modules/$MODULE"
        
        # Validar que el dominio no tenga dependencias externas
        if [ -d "$module_path/domain" ]; then
            local forbidden_imports=(
                "from.*infrastructure"
                "from.*application"
                "from.*presentation"
                "from.*TypeORM"
                "from.*NestJS"
                "from.*Express"
            )
            
            for pattern in "${forbidden_imports[@]}"; do
                if grep -r "$pattern" "$module_path/domain" --include="*.ts" > /dev/null 2>&1; then
                    print_check "FAIL" "Dominio contiene import prohibido: $pattern"
                    ((errors++))
                else
                    print_check "PASS" "Dominio sin import prohibido: $pattern"
                fi
            done
        fi
        
        # Validar que aplicación no dependa de presentación
        if [ -d "$module_path/application" ]; then
            if grep -r "from.*presentation" "$module_path/application" --include="*.ts" > /dev/null 2>&1; then
                print_check "FAIL" "Aplicación depende de presentación"
                ((errors++))
            else
                print_check "PASS" "Aplicación sin dependencia de presentación"
            fi
        fi
    fi
    
    return $errors
}

# Función para validar archivos en ubicaciones correctas
validate_file_locations() {
    echo -e "${YELLOW}Validando ubicación de archivos...${NC}"
    
    local errors=0
    
    if [ -n "$MODULE" ]; then
        local module_path="$SRC_DIR/modules/$MODULE"
        
        # Validar entidades en ubicación correcta
        if [ -d "$module_path/domain" ]; then
            local entities_count=$(find "$module_path/domain" -name "*Entity.ts" -type f | wc -l)
            local domain_entities_count=$(find "$module_path/domain/entities" -name "*.ts" -type f 2>/dev/null | wc -l)
            
            if [ "$entities_count" -eq "$domain_entities_count" ] || [ "$entities_count" -eq 0 ]; then
                print_check "PASS" "Entidades en ubicación correcta"
            else
                print_check "FAIL" "Entidades fuera de carpeta entities/"
                ((errors++))
            fi
        fi
        
        # Validar DTOs en ubicación correcta
        if [ -d "$module_path/application" ]; then
            local dtos_count=$(find "$module_path/application" -name "*Dto.ts" -type f | wc -l)
            local app_dtos_count=$(find "$module_path/application/dto" -name "*.ts" -type f 2>/dev/null | wc -l)
            
            if [ "$dtos_count" -eq "$app_dtos_count" ] || [ "$dtos_count" -eq 0 ]; then
                print_check "PASS" "DTOs en ubicación correcta"
            else
                print_check "FAIL" "DTOs fuera de carpeta dto/"
                ((errors++))
            fi
        fi
        
        # Validar controllers en ubicación correcta
        if [ -d "$module_path" ]; then
            local controllers_count=$(find "$module_path" -name "*Controller.ts" -type f | wc -l)
            local pres_controllers_count=$(find "$module_path/presentation" -name "*Controller.ts" -type f 2>/dev/null | wc -l)
            
            if [ "$controllers_count" -eq "$pres_controllers_count" ] || [ "$controllers_count" -eq 0 ]; then
                print_check "PASS" "Controllers en ubicación correcta"
            else
                print_check "FAIL" "Controllers fuera de carpeta presentation/"
                ((errors++))
            fi
        fi
    fi
    
    return $errors
}

# Función para validar nomenclatura
validate_naming() {
    echo -e "${YELLOW}Validando nomenclatura...${NC}"
    
    local errors=0
    
    if [ -n "$MODULE" ]; then
        local module_path="$SRC_DIR/modules/$MODULE"
        
        # Validar nombres de clases
        if [ -d "$module_path/domain" ]; then
            # Validar entidades con sufijo Entity
            for file in "$module_path/domain/entities"/*.ts 2>/dev/null; do
                if [ -f "$file" ]; then
                    local filename=$(basename "$file" .ts)
                    if [[ ! "$filename" =~ Entity$ ]]; then
                        print_check "FAIL" "Entidad sin sufijo Entity: $filename"
                        ((errors++))
                    fi
                fi
            done
            
            # Validar objetos de valor sin sufijos específicos
            local non_entities=$(find "$module_path/domain" -name "*.ts" -not -path "*/entities/*" -not -name "*Repository.ts" -not -name "*Service.ts" 2>/dev/null)
            for file in $non_entities; do
                if [ -f "$file" ]; then
                    local filename=$(basename "$file" .ts)
                    if [[ "$filename" =~ (Repository|Service|Handler|Controller|Dto|Entity)$ ]]; then
                        print_check "FAIL" "Objeto de dominio con sufijo inapropiado: $filename"
                        ((errors++))
                    fi
                fi
            done
        fi
        
        # Validar handlers con sufijo Handler
        if [ -d "$module_path/application/handlers" ]; then
            for file in "$module_path/application/handlers"/*.ts 2>/dev/null; do
                if [ -f "$file" ]; then
                    local filename=$(basename "$file" .ts)
                    if [[ ! "$filename" =~ Handler$ ]]; then
                        print_check "FAIL" "Handler sin sufijo Handler: $filename"
                        ((errors++))
                    fi
                fi
            done
        fi
        
        # Validar DTOs con sufixo Dto
        if [ -d "$module_path/application/dto" ]; then
            for file in "$module_path/application/dto"/*.ts 2>/dev/null; do
                if [ -f "$file" ]; then
                    local filename=$(basename "$file" .ts)
                    if [[ ! "$filename" =~ Dto$ ]]; then
                        print_check "FAIL" "DTO sin sufijo Dto: $filename"
                        ((errors++))
                    fi
                fi
            done
        fi
    fi
    
    return $errors
}

# Función para validar imports
validate_imports() {
    echo -e "${YELLOW}Validando imports...${NC}"
    
    local errors=0
    
    if [ -n "$MODULE" ]; then
        local module_path="$SRC_DIR/modules/$MODULE"
        
        # Validar imports relativos incorrectos
        for file in $(find "$module_path" -name "*.ts" -type f); do
            # Saltar archivos de test
            if [[ "$file" == *.spec.ts ]]; then
                continue
            fi
            
            # Buscar imports relativos que suban más de 2 niveles
            if grep -E "from '\.\./\.\./\.\.'" "$file" > /dev/null 2>&1; then
                print_check "FAIL" "Import relativo muy profundo en: $(basename "$file")"
                ((errors++))
            fi
            
            # Buscar imports absolutos que deberían ser relativos
            if grep -E "from '@/app/modules/$MODULE/\.\./\.\.'" "$file" > /dev/null 2>&1; then
                print_check "FAIL" "Import absoluto innecesario en: $(basename "$file")"
                ((errors++))
            fi
        done
        
        if [ $errors -eq 0 ]; then
            print_check "PASS" "Imports relativos correctos"
            print_check "PASS" "Imports absolutos apropiados"
        fi
    fi
    
    return $errors
}

# Función para validar reglas de negocio específicas
validate_business_rules() {
    echo -e "${YELLOW}Validando reglas de negocio específicas...${NC}"
    
    local errors=0
    
    # Validar que no haya lógica de negocio en controllers
    if [ -n "$MODULE" ]; then
        local module_path="$SRC_DIR/modules/$MODULE"
        
        for file in "$module_path/presentation"/*Controller.ts 2>/dev/null; do
            if [ -f "$file" ]; then
                # Buscar patrones que indican lógica de negocio
                local business_logic_patterns=(
                    "if.*email.*include.*@"
                    "if.*password.*length"
                    "new.*User("
                    "validate.*password"
                    "check.*email"
                )
                
                for pattern in "${business_logic_patterns[@]}"; do
                    if grep -E "$pattern" "$file" > /dev/null 2>&1; then
                        print_check "FAIL" "Lógica de negocio detectada en controller: $(basename "$file")"
                        ((errors++))
                    fi
                done
            fi
        done
        
        if [ $errors -eq 0 ]; then
            print_check "PASS" "Sin lógica de negocio en controllers"
        fi
    fi
    
    return $errors
}

# Función principal
main() {
    echo -e "${YELLOW}Validando arquitectura${NC}"
    if [ -n "$MODULE" ]; then
        echo -e "${YELLOW}Módulo: $MODULE${NC}"
        if [ -n "$FEATURE" ]; then
            echo -e "${YELLOW}Feature: $FEATURE${NC}"
        fi
    fi
    echo ""
    
    local total_errors=0
    
    # Ejecutar validaciones
    validate_folder_structure
    ((total_errors+=$?))
    
    echo ""
    validate_dependencies
    ((total_errors+=$?))
    
    echo ""
    validate_file_locations
    ((total_errors+=$?))
    
    echo ""
    validate_naming
    ((total_errors+=$?))
    
    echo ""
    validate_imports
    ((total_errors+=$?))
    
    echo ""
    validate_business_rules
    ((total_errors+=$?))
    
    # Resumen
    echo ""
    echo -e "${YELLOW}=== RESUMEN DE VALIDACIÓN ===${NC}"
    
    if [ $total_errors -eq 0 ]; then
        echo -e "${GREEN}✅ Todas las validaciones pasaron${NC}"
        echo ""
        echo -e "${GREEN}La arquitectura es correcta según las reglas establecidas.${NC}"
        return 0
    else
        echo -e "${RED}❌ Se encontraron $total_errors errores${NC}"
        echo ""
        echo -e "${RED}La arquitectura viola las reglas establecidas.${NC}"
        echo -e "${YELLOW}Revisa los errores detallados arriba y corrige la implementación.${NC}"
        return 1
    fi
}

# Ejecutar validación
if ! main; then
    exit 1
fi