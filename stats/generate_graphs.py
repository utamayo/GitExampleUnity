#!/usr/bin/env python3
"""
stats/scripts/generate_graphs.py

Genera gráficos de commits por rama e issues por usuario.
Los datos deberían provenir del propio repositorio (por ejemplo, generados por git_stats.sh).
Por ahora, se incluyen secciones marcadas donde puedes insertar la lectura de datos real.
"""

import matplotlib.pyplot as plt
import os

PLOTS_DIR = "stats/plots"
os.makedirs(PLOTS_DIR, exist_ok=True)

# -------------------------------------------------------------------
# Aquí deberías cargar los datos reales desde algún archivo o fuente.
# Por ejemplo, podrías guardar datos en JSON desde git_stats.sh y leerlos aquí.
# Ejemplo de estructura esperada:
# commits_by_branch = {"main": 120, "dev": 80, "feature-x": 45}
# issues_by_user = {"alice": (5, 2), "bob": (3, 4), "carla": (10, 1)}
# -------------------------------------------------------------------

commits_by_branch = {}   # ← Reemplaza esto por tus datos reales
issues_by_user = {}      # ← Reemplaza esto por tus datos reales

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
