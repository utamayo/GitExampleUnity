#!/bin/bash
# stats/scripts/git_stats.sh
# Genera estadísticas completas de commits e issues (por usuario o globales)
# y las guarda en stats/stats.md + exporta datos a stats/data.json

OUTPUT_FILE="stats/stats.md"
PLOTS_DIR="stats/plots"
DATA_FILE="stats/data.json"
TARGET_USER=$1

mkdir -p "$PLOTS_DIR"

# Colores (solo para salida local)
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
RESET='\033[0m'

# Encabezado del informe Markdown
{
echo "# 📊 Estadísticas del Repositorio"
echo
echo "_Última actualización: $(date '+%Y-%m-%d %H:%M:%S')_"
echo
} > "$OUTPUT_FILE"

# --- TOP AUTORES ---
if [ -z "$TARGET_USER" ]; then
  echo "## 👥 Top autores (todas las ramas)" >> "$OUTPUT_FILE"
  git shortlog --summary --numbered --all --no-merges |
    awk '{printf "%s %s\n", $1, substr($0, index($0,$2))}' |
    awk '{print "- **"$2"**: "$1" commits"}' >> "$OUTPUT_FILE"
  echo >> "$OUTPUT_FILE"
fi

# --- COMMITS POR RAMA ---
echo "## 🌿 Commits por rama" >> "$OUTPUT_FILE"
echo >> "$OUTPUT_FILE"

for branch in $(git branch -r | grep -v HEAD); do
  echo "### $branch" >> "$OUTPUT_FILE"
  if [ -z "$TARGET_USER" ]; then
    git shortlog --summary --numbered --no-merges $branch |
      awk '{print "- **"$2"**: "$1" commits"}' >> "$OUTPUT_FILE"
  else
    count=$(git log $branch --no-merges --author="$TARGET_USER" --pretty=oneline | wc -l)
    echo "- $TARGET_USER: $count commits" >> "$OUTPUT_FILE"
  fi
  echo >> "$OUTPUT_FILE"
done

# --- Exportar datos JSON para gráficos ---
echo "{" > "$DATA_FILE"

# Commits por rama
echo '  "commits_by_branch": {' >> "$DATA_FILE"
first=true
for branch in $(git branch -r | grep -v HEAD); do
  count=$(git rev-list --no-merges --count $branch)
  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> "$DATA_FILE"
  fi
  echo -n "    \"${branch#origin/}\": $count" >> "$DATA_FILE"
done
echo "  }," >> "$DATA_FILE"

# Issues por usuario (si gh disponible)
if command -v gh &>/dev/null; then
  echo '  "issues_by_user": {' >> "$DATA_FILE"
  first=true
  users=$(gh issue list --json assignees | jq -r '.[] | .assignees[].login' | sort | uniq)
  for user in $users; do
    open=$(gh issue list --assignee "$user" --state open --json number | jq length)
    closed=$(gh issue list --assignee "$user" --state closed --json number | jq length)
    if [ "$first" = true ]; then
      first=false
    else
      echo "," >> "$DATA_FILE"
    fi
    echo -n "    \"$user\": [$open, $closed]" >> "$DATA_FILE"
  done
  echo "  }" >> "$DATA_FILE"
else
  echo '  "issues_by_user": {}' >> "$DATA_FILE"
fi

echo "}" >> "$DATA_FILE"

# --- ISSUES (detalle en Markdown) ---
if command -v gh &>/dev/null; then
  echo "## 🐙 Issues (GitHub CLI)" >> "$OUTPUT_FILE"
  if [ -z "$TARGET_USER" ]; then
    users=$(gh issue list --json assignees | jq -r '.[] | .assignees[].login' | sort | uniq)
    if [ -z "$users" ]; then
      echo "_No hay issues asignadas a usuarios._" >> "$OUTPUT_FILE"
    else
      for user in $users; do
        open=$(gh issue list --assignee "$user" --state open --json number | jq length)
        closed=$(gh issue list --assignee "$user" --state closed --json number | jq length)
        echo "- **$user** → Abiertas: $open | Cerradas: $closed" >> "$OUTPUT_FILE"
      done
    fi
  else
    open=$(gh issue list --assignee "$TARGET_USER" --state open --json number | jq length)
    closed=$(gh issue list --assignee "$TARGET_USER" --state closed --json number | jq length)
    echo "- **$TARGET_USER** → Abiertas: $open | Cerradas: $closed" >> "$OUTPUT_FILE"
  fi
else
  echo "_⚠️ GitHub CLI (gh) no está instalado. No se pueden consultar issues._" >> "$OUTPUT_FILE"
fi

# Enlazamos los gráficos
echo >> "$OUTPUT_FILE"
echo "![Commits por rama](plots/commits_per_branch.png)" >> "$OUTPUT_FILE"
echo "![Issues por usuario](plots/issues_by_user.png)" >> "$OUTPUT_FILE"
