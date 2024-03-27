---
# tasks file for Project
- name: Create namespace
  kubernetes.core.k8s:
    state: present
    definition:
      apiVersion: v1
      kind: Namespace
      metadata:
        name: {{ ansible_operator_meta.name }}-{{ item.name }}
        labels:
          app.kubernetes.io/managed-by: "project-operator"
  loop: "{{ environments }}"

- name: Create a resource quota
  kubernetes.core.k8s:
    state: present
    definition:
      apiVersion: v1
      kind: ResourceQuota
      metadata:
        namespace: {{ ansible_operator_meta.name }}-{{ item.name }}
        name: resource-quota
        labels:
          app.kubernetes.io/managed-by: "project-operator"
      spec:
        hard:
          limits.cpu: "{{ item.resource.limits.cpu }}"
          limits.memory: "{{ item.resource.limits.memory }}"
          request.cpu: "{{ item.resource.request.cpu }}"
          request.memory: "{{ item.resource.request.memory }}"
  loop: "{{ environments }}"

- name: Create a member role building
  kubernetes.core.k8s:
    state: present
    definition:
      apiVersion: rbac.authorization.k8s.io/v1
      kind: RoleBinding
      metadata:
        name: {{ item[1] }}
        namespace: {{ ansible_operator_meta.name }}-{{ item[].name }}
        labels:
          app.kubernetes.io/managed-by: "project-operator"
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: edit
      subjects:
        - kind: ServiceAccount
          name: "{{ item[1] }}"
          namespace: users
  with_nested:
    - "{{ environments }}"
    - "{{ members }}"
