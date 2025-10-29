import matplotlib.pyplot as plt
import os

def plot_commits_per_branch(commits_by_branch):
    branches = list(commits_by_branch.keys())
    commits = list(commits_by_branch.values())
    
    plt.figure(figsize=(10, 6))
    plt.bar(branches, commits, color='blue')
    plt.xlabel('Ramas')
    plt.ylabel('Número de Commits')
    plt.title('Commits por Rama')
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig('stats/plots/commits_per_branch.png')

def plot_issues_by_user(issues_by_user):
    users = list(issues_by_user.keys())
    open_issues = [issue[0] for issue in issues_by_user.values()]
    closed_issues = [issue[1] for issue in issues_by_user.values()]

    width = 0.35  # Ancho de las barras
    x = range(len(users))

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.bar(x, open_issues, width, label='Abiertas', color='orange')
    ax.bar([p + width for p in x], closed_issues, width, label='Cerradas', color='cyan')

    ax.set_ylabel('Número de Issues')
    ax.set_title('Issues por Usuario')
    ax.set_xticks([p + width / 2 for p in x])
    ax.set_xticklabels(users)
    ax.legend()
    
    plt.tight_layout()
    plt.savefig('stats/plots/issues_by_user.png')

# Simulamos los datos, en producción estos vendrán del script
commits_by_branch = {'main': 120, 'dev': 80, 'feature-x': 45}
issues_by_user = {'usuario1': (5, 2), 'usuario2': (3, 4), 'usuario3': (10, 1)}

plot_commits_per_branch(commits_by_branch)
