# k8s-access-manager Helm Chart

Helm chart для управления RBAC доступом в Kubernetes с автоматической генерацией kubeconfig файлов.

# 🚀 Быстрый старт
1. Добавление репозитория
```bash
helm repo add k8s-access-manager https://Mef1st161.github.io/k8s-access-manager
helm repo update
```
2. Базовая установка
```bash
# Создаем namespace
kubectl create namespace users
```
# Устанавливаем чарт
`helm upgrade --install my-access k8s-access-manager/k8s-access-manager -n users`
# 📋 Возможности
✅ Создание ServiceAccounts для пользователей

✅ Назначение RBAC ролей и привязок

✅ Автоматическая генерация токенов

✅ Поддержка кластерных и неймспейсных ролей

✅ Генерация kubeconfig команд для доступа

✅ Переиспользование существующих ролей

# 🛠️ Конфигурация

Базовая конфигурация (values.yaml)

```yaml
global:
  namespace: "k8s-access-users"  # Неймспейс для ServiceAccounts
  createTokenSecrets: true        # Создавать секреты с токенами
```
# Предопределенные роли
```yaml
rbacRoles:
  cluster-readonly:
    create: true                  # Создавать эту роль
    clusterScope: true            # ClusterRole (true) или Role (false)
    rules: [...]                  # RBAC правила

  namespace-admin:
    create: true
    clusterScope: false
    rules: [...]
```
# Пользователи
```yaml
users:
  username:
    enabled: true
    serviceAccountName: "custom-sa"  # Опционально
    createTokenSecret: true
    clusterRoles:
      - "cluster-readonly"           # Наши роли
      - "k8s:view"                   # Стандартные роли Kubernetes
      - "custom:existing-role"       # Существующие кастомные роли
    namespaceRoles:
      - namespace: "my-namespace"
        role: "namespace-admin"
```
# 📝 Примеры использования

Пример 1: Read-only пользователь

```yaml
users:
  readonly-user:
    enabled: true
    clusterRoles:
      - "cluster-readonly"
Пример 2: Разработчик с доступом к неймспейсам
yaml
users:
  developer:
    enabled: true
    clusterRoles:
      - "cluster-readonly"
    namespaceRoles:
      - namespace: "development"
        role: "namespace-admin"
      - namespace: "staging" 
        role: "namespace-readonly"
```
Пример 3: CI/CD сервисный аккаунт

```yaml
users:
  gitlab-runner:
    enabled: true
    serviceAccountName: "gitlab-ci"
    namespaceRoles:
      - namespace: "ci-cd"
        role: "namespace-admin"
      - namespace: "applications"
        role: "namespace-admin"
 ```       
# 🎯 Использование существующих ролей

Стандартные роли Kubernetes

```yaml
clusterRoles:
  - "k8s:view"
  - "k8s:edit"
  - "k8s:admin"
Кастомные роли из кластера
yaml
clusterRoles:
  - "custom:my-cluster-role"
namespaceRoles:
  - namespace: "monitoring"
    role: "custom:grafana-admin"
```

# 🔄 Обновление

```bash
# Обновление релиза
helm upgrade my-access k8s-access-manager/k8s-access-manager -n users -f values.yaml
```
# Просмотр что будет обновлено (dry-run)
```
helm upgrade my-access k8s-access-manager/k8s-access-manager -n users -f values.yaml --dry-run
```
# 🗑️ Удаление

```bash
# Удаление релиза
helm uninstall my-access -n users
```
# Удаление с очисткой ресурсов
```
kubectl delete namespace users
```
# 📊 Проверка установки

```bash
# Проверить созданные ресурсы
kubectl get serviceaccounts -n users
kubectl get clusterrolebindings -l app.kubernetes.io/name=k8s-access-manager
kubectl get rolebindings --all-namespaces -l app.kubernetes.io/name=k8s-access-manager
```

# Проверить доступ
```
kubectl --context=user-context get pods
```

# Использование скрипта для получения kubeconfig
```bash
#Скрипт находится в папке scripts/generate_add_cluster_commands.sh
bash generate_add_cluster_commands.sh username
```

## ❗️ Важные замечания

- Роли создаются только один раз и используются повторно
    
- Установите значение create: false для уже существующих ролей
    
- Используйте префиксы: k8s: для встроенных ролей, custom: для существующих пользовательских ролей
    
- Секреты токенов необязательны, но рекомендуются для упрощения доступа
