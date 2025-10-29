#!/usr/bin/env python3
"""
stats/scripts/generate_graphs.py

Lee stats/data.json (generado por git_stats.sh)
y crea gráficos PNG en stats/plots/
"""

import matplotlib.pyplot as plt
import os
import json

PLOTS_DIR = "stats/plots"
DATA_FILE = "stats/data.json"
os.makedirs(PLOTS_DIR, exist_ok=True)

# Leer datos desde el JSON exportado
if not os.path.exists(DATA_FILE):
    print(f"⚠️ No se encontró {DATA_FILE}. No se pueden generar gráficos.")
    exit(0)

with open(DATA_FILE, "r") as f:
    data = json.load(f)

commits_by_branch = data.get("commits_by_branch", {})
issues_by_user = data.get("issues_by_user", {})

# --- Commits por rama ---
if commits_by_branch:
    plt.figure(figsize=(8, 5))
    plt.bar(commits_by_branch.keys(), commits_by_branch.values(), color='royalblue')
    plt.title("Commits por Rama")
    plt.xlabel("Ramas")
    plt.ylabel("Commits")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(os.path.join(PLOTS_DIR, "commits_per_branch.png"))
    plt.close()
else:
    print("⚠️ No hay datos de commits para graficar.")

# --- Issues por usuario ---
if issues_by_user:
    users = list(issues_by_user.keys())
    open_issues = [issues_by_user[u][0] for u in users]
    closed_issues = [issues_by_user[u][1] for u in users]

    x = range(len(users))
    plt.figure(figsize=(8, 5))
    plt.bar(x, open_issues, width=0.4, label="Abiertas", color='orange')
    plt.bar([i + 0.4 for i in x], closed_issues, width=0.4, label="Cerradas", color='seagreen')
    plt.xticks([i + 0.2 for i in x], users, rotation=45)
    plt.title("Issues por Usuario")
    plt.xlabel("Usuarios")
    plt.ylabel("Cantidad")
    plt.legend()
    plt.tight_layout()
    plt.savefig(os.path.join(PLOTS_DIR, "issues_by_user.png"))
    plt.close()
else:
    print("⚠️ No hay datos de issues para graficar.")
