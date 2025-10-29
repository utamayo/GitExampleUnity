#!/bin/bash
# git_stats.sh
# Muestra estadísticas completas de commits y issues por usuario o globales

# Colores
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

# Usuario objetivo (opcional)
TARGET_USER=$1

# Archivo de salida
OUTPUT_FILE="stats/stats.md"

# Si no hay usuario, mostrar top global
if [ -z "$TARGET_USER" ]; then
  echo -e "${BLUE}===========================================" >> $OUTPUT_FILE
  echo -e "   👥 TOP AUTORES (TODAS LAS RAMAS)" >> $OUTPUT_FILE
  echo -e "===========================================" >> $OUTPUT_FILE
  git shortlog --summary --numbered --all --no-merges |
    awk -v magenta="$MAGENTA" -v green="$GREEN" -v reset="$RESET" '{print magenta $1 reset " " green substr($0, index($0,$2)) reset}' >> $OUTPUT_FILE
  echo >> $OUTPUT_FILE
fi

echo -e "${BLUE}===========================================" >> $OUTPUT_FILE
echo -e "   📊 COMMITS POR RAMA" >> $OUTPUT_FILE
echo -e "===========================================" >> $OUTPUT_FILE
echo >> $OUTPUT_FILE

# Listar ramas remotas (excluyendo HEAD)
for branch in $(git branch -r | grep -v HEAD); do
  echo -e "${YELLOW}--- $branch ---${RESET}" >> $OUTPUT_FILE
  if [ -z "$TARGET_USER" ]; then
    git shortlog --summary --numbered --no-merges $branch |
      awk -v cyan="$CYAN" -v green="$GREEN" -v reset="$RESET" '{print cyan $1 reset " " green substr($0, index($0,$2)) reset}' >> $OUTPUT_FILE
  else
    echo -e "${CYAN}Commits de $TARGET_USER:${RESET}" >> $OUTPUT_FILE
    git log $branch --no-merges --author="$TARGET_USER" --pretty=oneline | wc -l | xargs echo "Total commits:" >> $OUTPUT_FILE
  fi
  echo >> $OUTPUT_FILE
done

# Verificar si gh está disponible
if command -v gh &>/dev/null; then
  echo -e "${BLUE}===========================================" >> $OUTPUT_FILE
  echo -e "   🐙 ISSUES (GITHUB CLI)" >> $OUTPUT_FILE
  echo -e "===========================================" >> $OUTPUT_FILE

  if [ -z "$TARGET_USER" ]; then
    echo -e "${CYAN}Usuarios con issues asignadas:${RESET}" >> $OUTPUT_FILE
    users=$(gh issue list --json assignees | jq -r '.[] | .assignees[].login' | sort | uniq)
    if [ -z "$users" ]; then
      echo -e "${YELLOW}No hay issues asignadas a usuarios.${RESET}" >> $OUTPUT_FILE
    else
      for user in $users; do
        open=$(gh issue list --assignee "$user" --state open --json number | jq length)
        closed=$(gh issue list --assignee "$user" --state closed --json number | jq length)
        echo -e "${GREEN}$user${RESET} → Abiertas: ${YELLOW}$open${RESET} | Cerradas: ${CYAN}$closed${RESET}" >> $OUTPUT_FILE
      done
    fi
  else
    echo -e "${CYAN}Issues de $TARGET_USER:${RESET}" >> $OUTPUT_FILE
    open=$(gh issue list --assignee "$TARGET_USER" --state open --json number | jq length)
    closed=$(gh issue list --assignee "$TARGET_USER" --state closed --json number | jq length)
    echo -e "${GREEN}$TARGET_USER${RESET} → Abiertas: ${YELLOW}$open${RESET} | Cerradas: ${CYAN}$closed${RESET}" >> $OUTPUT_FILE
  fi
else
  echo -e "${YELLOW}⚠️ GitHub CLI (gh) no está instalado. No se pueden consultar issues.${RESET}" >> $OUTPUT_FILE
  echo "Instálalo con: https://cli.github.com/" >> $OUTPUT_FILE
fi
