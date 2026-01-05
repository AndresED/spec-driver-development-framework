#!/bin/bash

# run-tests.sh - Script para ejecutar pruebas con validaciones

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función de ayuda
show_help() {
    echo "Uso: $0 [options] [module] [feature]"
    echo ""
    echo "Ejecuta pruebas con validaciones completas del sistema."
    echo ""
    echo "Argumentos:"
    echo "  module    Nombre del módulo (opcional)"
    echo "  feature   Nombre de la feature (opcional)"
    echo ""
    echo "Opciones:"
    echo "  -c, --coverage    Genera reporte de cobertura"
    echo "  -w, --watch       Modo watch para desarrollo"
    echo "  -u, --unit        Ejecuta solo pruebas unitarias"
    echo "  -i, --integration Ejecuta solo pruebas de integración"
    echo "  -e, --e2e         Ejecuta solo pruebas E2E"
    echo "  -a, --all         Ejecuta todas las pruebas (default)"
    echo "  -v, --verbose     Salida detallada"
    echo "  -f, --fast        Skip validaciones de arquitectura"
    echo "  -h, --help        Muestra esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0                           # Todas las pruebas con validaciones"
    echo "  $0 -c                         # Con cobertura"
    echo "  $0 users                      # Solo módulo users"
    echo "  $0 users create-user           # Feature específica"
    echo "  $0 -u users                   # Unit tests del módulo users"
    echo "  $0 -i -c                      # Integration tests con cobertura"
    echo "  $0 -e                         # Solo E2E tests"
}

# Argumentos por defecto
COVERAGE=false
WATCH=false
TEST_TYPE="all"
VERBOSE=false
FAST=false
MODULE=""
FEATURE=""

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--coverage)
            COVERAGE=true
            shift
            ;;
        -w|--watch)
            WATCH=true
            shift
            ;;
        -u|--unit)
            TEST_TYPE="unit"
            shift
            ;;
        -i|--integration)
            TEST_TYPE="integration"
            shift
            ;;
        -e|--e2e)
            TEST_TYPE="e2e"
            shift
            ;;
        -a|--all)
            TEST_TYPE="all"
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--fast)
            FAST=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            if [ -z "$MODULE" ]; then
                MODULE="$1"
            elif [ -z "$FEATURE" ]; then
                FEATURE="$1"
            else
                echo -e "${RED}Error: Demasiados argumentos${NC}"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Variables globales
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
START_TIME=$(date +%s)

# Función para imprimir timestamp
print_timestamp() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

# Función para ejecutar comando con manejo de errores
run_command() {
    local cmd="$1"
    local description="$2"
    local optional="${3:-false}"
    
    print_timestamp "Ejecutando: $description"
    
    if [ "$VERBOSE" = true ]; then
        echo -e "${YELLOW}Comando: $cmd${NC}"
    fi
    
    if [ "$optional" = true ]; then
        eval "$cmd" || {
            echo -e "${YELLOW}Advertencia: $description falló (opcional)${NC}"
            return 0
        }
    else
        eval "$cmd" || {
            echo -e "${RED}Error: $description falló${NC}"
            ((FAILED_TESTS++))
            return 1
        }
    fi
    
    ((PASSED_TESTS++))
    echo -e "${GREEN}✅ $description completado${NC}"
}

# Función para validar cobertura de pruebas
validate_coverage() {
    local coverage_file="coverage/lcov-report/index.html"
    
    if [ -f "$coverage_file" ]; then
        # Extraer porcentaje de cobertura
        local coverage=$(npm test -- --coverage --coverageReporters=text-summary 2>&1 | grep -o 'Lines\s*:\s*[0-9.]*%' | grep -o '[0-9.]*' | head -1)
        
        if [ -n "$coverage" ]; then
            local coverage_num=$(echo "$coverage" | cut -d'.' -f1)
            
            if [ "$coverage_num" -eq 100 ]; then
                echo -e "${GREEN}✅ Cobertura 100% - Cumple con el requerimiento${NC}"
            else
                echo -e "${RED}❌ Cobertura $coverage% - Se requiere 100%${NC}"
                ((FAILED_TESTS++))
                return 1
            fi
        else
            echo -e "${YELLOW}⚠️  No se pudo determinar el porcentaje de cobertura${NC}"
        fi
    else
        echo -e "${RED}❌ Archivo de cobertura no encontrado${NC}"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Función para construir el patrón de pruebas
build_test_pattern() {
    local pattern=""
    
    if [ -n "$MODULE" ]; then
        if [ -n "$FEATURE" ]; then
            # Feature específica
            case $TEST_TYPE in
                "unit")
                    pattern="test/modules/$MODULE/**/*$FEATURE*.spec.ts"
                    ;;
                "integration")
                    pattern="test/integration/**/*$MODULE*$FEATURE*.spec.ts"
                    ;;
                "e2e")
                    pattern="test/e2e/**/*$MODULE*$FEATURE*.spec.ts"
                    ;;
                *)
                    pattern="test/**/*$MODULE*$FEATURE*.spec.ts"
                    ;;
            esac
        else
            # Módulo específico
            case $TEST_TYPE in
                "unit")
                    pattern="test/modules/$MODULE/**/*.spec.ts"
                    ;;
                "integration")
                    pattern="test/integration/**/*$MODULE*.spec.ts"
                    ;;
                "e2e")
                    pattern="test/e2e/**/*$MODULE*.spec.ts"
                    ;;
                *)
                    pattern="test/**/*$MODULE*.spec.ts"
                    ;;
            esac
        fi
    else
        # Todos los tests
        case $TEST_TYPE in
            "unit")
                pattern="test/modules/**/*.spec.ts"
                ;;
            "integration")
                pattern="test/integration/**/*.spec.ts"
                ;;
            "e2e")
                pattern="test/e2e/**/*.spec.ts"
                ;;
            *)
                pattern="test/**/*.spec.ts"
                ;;
        esac
    fi
    
    echo "$pattern"
}

# Función para construir comando de Jest
build_jest_command() {
    local cmd="npm test"
    
    # Añadir patrón
    local pattern=$(build_test_pattern)
    cmd="$cmd -- $pattern"
    
    # Añadir opciones
    if [ "$COVERAGE" = true ]; then
        cmd="$cmd --coverage"
    fi
    
    if [ "$WATCH" = true ]; then
        cmd="$cmd --watch"
    fi
    
    if [ "$VERBOSE" = true ]; then
        cmd="$cmd --verbose"
    fi
    
    if [ "$COVERAGE" = false ]; then
        cmd="$cmd --passWithNoTests"
    fi
    
    echo "$cmd"
}

# Función para ejecutar validaciones de arquitectura
run_architecture_validation() {
    if [ "$FAST" = true ]; then
        print_timestamp "Omitiendo validación de arquitectura (modo fast)"
        return 0
    fi
    
    print_timestamp "Validando arquitectura..."
    
    if [ -f "./scripts/validate-architecture.sh" ]; then
        if [ -n "$MODULE" ]; then
            if [ -n "$FEATURE" ]; then
                ./scripts/validate-architecture.sh "$MODULE" "$FEATURE"
            else
                ./scripts/validate-architecture.sh "$MODULE"
            fi
        else
            ./scripts/validate-architecture.sh
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Validación de arquitectura exitosa${NC}"
            ((PASSED_TESTS++))
        else
            echo -e "${RED}❌ Validación de arquitectura fallida${NC}"
            ((FAILED_TESTS++))
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  Script de validación de arquitectura no encontrado${NC}"
    fi
}

# Función para ejecutar pruebas de linting
run_linting() {
    if [ "$FAST" = true ]; then
        print_timestamp "Omitiendo linting (modo fast)"
        return 0
    fi
    
    print_timestamp "Ejecutando linting..."
    
    if [ -f "package.json" ] && grep -q "lint" "package.json"; then
        npm run lint
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Linting exitoso${NC}"
            ((PASSED_TESTS++))
        else
            echo -e "${RED}❌ Linting fallido${NC}"
            ((FAILED_TESTS++))
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  Script de linting no encontrado${NC}"
    fi
}

# Función para ejecutar pruebas de tipo checking
run_type_checking() {
    if [ "$FAST" = true ]; then
        print_timestamp "Omitiendo type checking (modo fast)"
        return 0
    fi
    
    print_timestamp "Ejecutando type checking..."
    
    if [ -f "tsconfig.json" ]; then
        npx tsc --noEmit
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Type checking exitoso${NC}"
            ((PASSED_TESTS++))
        else
            echo -e "${RED}❌ Type checking fallido${NC}"
            ((FAILED_TESTS++))
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  tsconfig.json no encontrado${NC}"
    fi
}

# Función para mostrar resumen
show_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    echo ""
    echo -e "${BLUE}=== RESUMEN DE EJECUCIÓN ===${NC}"
    echo -e "Duración: ${YELLOW}${duration}s${NC}"
    echo -e "Tests pasados: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Tests fallidos: ${RED}$FAILED_TESTS${NC}"
    echo -e "Total de validaciones: ${YELLOW}$((PASSED_TESTS + FAILED_TESTS))${NC}"
    
    if [ "$COVERAGE" = true ] && [ -f "coverage/lcov-report/index.html" ]; then
        echo -e "Reporte de cobertura: ${BLUE}coverage/lcov-report/index.html${NC}"
    fi
    
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 Todas las validaciones pasaron exitosamente${NC}"
        echo -e "${GREEN}El código cumple con todos los estándares de calidad${NC}"
        return 0
    else
        echo -e "${RED}❌ Se encontraron $FAILED_TESTS errores${NC}"
        echo -e "${RED}El código no cumple con los estándares de calidad${NC}"
        echo -e "${YELLOW}Por favor, corrige los errores antes de continuar${NC}"
        return 1
    fi
}

# Función principal
main() {
    echo -e "${BLUE}=== EJECUCIÓN DE PRUEBAS Y VALIDACIONES ===${NC}"
    
    if [ -n "$MODULE" ]; then
        echo -e "${BLUE}Módulo: $MODULE${NC}"
        if [ -n "$FEATURE" ]; then
            echo -e "${BLUE}Feature: $FEATURE${NC}"
        fi
    fi
    
    echo -e "${BLUE}Tipo: $TEST_TYPE${NC}"
    echo -e "${BLUE}Cobertura: $COVERAGE${NC}"
    echo -e "${BLUE}Modo fast: $FAST${NC}"
    echo ""
    
    # Ejecutar validaciones previas
    run_type_checking
    run_linting
    run_architecture_validation
    
    echo ""
    
    # Construir y ejecutar pruebas
    local jest_cmd=$(build_jest_command)
    print_timestamp "Ejecutando pruebas Jest..."
    
    if [ "$VERBOSE" = true ]; then
        echo -e "${YELLOW}Comando Jest: $jest_cmd${NC}"
    fi
    
    eval "$jest_cmd"
    local jest_exit_code=$?
    
    if [ $jest_exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ Pruebas Jest exitosas${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}❌ Pruebas Jest fallidas${NC}"
        ((FAILED_TESTS++))
    fi
    
    # Validar cobertura si se solicitó
    if [ "$COVERAGE" = true ]; then
        echo ""
        validate_coverage
    fi
    
    # Mostrar resumen
    show_summary
}

# Ejecutar validación de ambiente
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: package.json no encontrado. ¿Estás en el directorio correcto?${NC}"
    exit 1
fi

if [ ! -d "test" ]; then
    echo -e "${RED}Error: Directorio test/ no encontrado${NC}"
    exit 1
fi

# Ejecutar función principal
main