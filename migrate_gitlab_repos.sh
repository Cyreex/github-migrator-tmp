debug_level=0 #Set 1 to enable debug output
old_gitlab="gitlab.tpondemand.net"
new_gitlab="awsgitlab.tpondemand.net"

working_dir=$(pwd)
git_repos=$(find ./ -name "*.git" -type d)

for git_repo in ${git_repos}; do
  [ $debug_level -eq 1 ] && echo "Change folder to ${git_repo}"
  cd ${git_repo}/../
  git_repo_url=$(git remote get-url --push origin)
  is_old_gitlab=$(echo $git_repo_url | grep ^git@${old_gitlab} -c || true)
  [ $debug_level -eq 1 ] && echo "This is old gitlab: ${is_old_gitlab}"

  if [ ${is_old_gitlab} -eq 1 ]; then
    git_repo_path=$(cut -d: -f2 <<< ${git_repo_url})
    [ $debug_level -eq 1 ] && echo "Check the repo ${git_repo_path} exists in ${new_gitlab}"

    git ls-remote git@${new_gitlab}:${git_repo_path} &>/dev/null
    exit_status=$?
    [ $debug_level -eq 1 ] && echo "git ls-remote git@${new_gitlab}:${git_repo_path} exit_status: ${exit_status}"

    if [ ${exit_status} -eq 0 ]; then
      echo "The repo ${git_repo_path} exists in ${new_gitlab}. Set a new remote url for the repo ${git_repo}"
      git remote set-url origin git@${new_gitlab}:${git_repo_path}
    else
      [ $debug_level -eq 1 ] && echo "The repo ${git_repo_path} doesn't exists in ${new_gitlab}. No changes needed."
    fi
  fi
  cd ${working_dir}
done
