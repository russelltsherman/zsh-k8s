#!/usr/bin/env bash

DIR="$( cd "$( dirname $0:A )" && pwd )"
export PATH=$DIR/bin:$PATH

# source shell autocompletion for installed commands
[[ $commands[helm] ]] && source <(helm completion zsh)
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
[[ $commands[minikube] ]] && source <(minikube completion zsh)


# #  exec into a pod
# kx () {
# 	local pod=($(kubectl get pods --all-namespaces -owide | fzf | awk '{print $1, $2}'))
# 	local cmd=${@:-"bash"}

# 	echo kubectl exec -it --namespace $pod[1] $pod[2] $cmd
# 	kubectl exec -it --namespace $pod[1] $pod[2] $cmd
# }

# # logs
# kl () {
# 	local pod=($(kubectl get pods --all-namespaces -owide | fzf | awk '{print $1, $2}'))
# 	local attr=${@:-""}

# 	echo kubectl logs -f $attr --namespace $pod[1] $pod[2]
# 	kubectl logs -f $attr --namespace $pod[1] $pod[2]
# }

# # kubectl context/namespace switcher!
# kcc () {
#   usage () {
#     echo -en "Usage: $0 <context> <namespace>\n"
#   }
#   result () {
#     echo -en "-> Context: \e[96m$context\e[0m\n-> Namespace: \e[92m$namespace\n\e[0m"
#   }
#   if  [ $# -eq 0 ] ; then
#     ## If no options, print the current context/cluster and namespace
#     context="$(kubectl config current-context 2>/dev/null)"
#     namespace="$(kubectl config view -o "jsonpath={.contexts[?(@.name==\"$context\")].context.namespace}")"
#     result
#   elif [ $# -eq 2 ]; then
#     ## If options, assume time to set
#     context="$1"
#     namespace="$2"
#     kubectl config use-context "$context"
#     kubectl config set-context "$context" --namespace="$namespace"
#     result
#   else
#     usage
#   fi
# }

# ------------------------------------------------------------------------------
# Impromptu Prompt Segment Function
# ------------------------------------------------------------------------------
impromptu::prompt::kubecontext() {
  IMPROMPTU_KUBECONTEXT_SHOW="true"
  IMPROMPTU_KUBECONTEXT_PREFIX=""
  IMPROMPTU_KUBECONTEXT_SUFFIX=" "
  # Additional space is added because ☸️ is much bigger than the other symbols
  IMPROMPTU_KUBECONTEXT_SYMBOL="☸️  "
  IMPROMPTU_KUBECONTEXT_COLOR="cyan"
  IMPROMPTU_KUBECONTEXT_NAMESPACE_SHOW="true"
  IMPROMPTU_KUBECONTEXT_COLOR_GROUPS=()

  chk::command kubectl || return

  [[ "$IMPROMPTU_KUBECONTEXT_SHOW" == "true" ]] || return

  local kube_context=$(kubectl config current-context 2>/dev/null)
  [[ -z $kube_context ]] && return

  if [[ $IMPROMPTU_KUBECONTEXT_NAMESPACE_SHOW == true ]]
  then
    local kube_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
    [[ -n $kube_namespace && "$kube_namespace" != "default" ]] && kube_context="$kube_context ($kube_namespace)"
  fi

  # Apply custom color to section if $kube_context matches a pattern defined in IMPROMPTU_KUBECONTEXT_COLOR_GROUPS array.
  # See Options.md for usage example.
  local len=${#IMPROMPTU_KUBECONTEXT_COLOR_GROUPS[@]}
  local it_to=$((len / 2))
  local 'section_color' 'i'
  for ((i = 1; i <= $it_to; i++))
  do
    local idx=$(((i - 1) * 2))
    local color="${IMPROMPTU_KUBECONTEXT_COLOR_GROUPS[$idx + 1]}"
    local pattern="${IMPROMPTU_KUBECONTEXT_COLOR_GROUPS[$idx + 2]}"
    if [[ "$kube_context" =~ "$pattern" ]]
    then
      section_color=$color
      break
    fi
  done

  [[ -z "$section_color" ]] && section_color=$IMPROMPTU_KUBECONTEXT_COLOR

  impromptu::segment "$section_color" \
    "${IMPROMPTU_KUBECONTEXT_PREFIX}${IMPROMPTU_KUBECONTEXT_SYMBOL}${kube_context}${IMPROMPTU_KUBECONTEXT_SUFFIX}"
}
