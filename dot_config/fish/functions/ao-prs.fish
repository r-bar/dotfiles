function ao-prs --description "List all relavent AppOmni PRs requiring action"
  gh pr list --repo appomni/appomni --search 'is:pr is:open review-requested:@me' $argv
  gh pr list --repo appomni/appomni-ops --search 'is:pr is:open review-requested:@me' $argv
  gh pr list --repo appomni/ao_request_flow $argv
  gh pr list --repo appomni/ao_saas_connector_catalog $argv
  gh pr list --repo appomni/gsync_experimental $argv
  gh pr list --repo appomni/ao_gsync_client $argv
  gh pr list --repo appomni/appomni-looker-etl $argv
  gh pr list --repo appomni/gsyncms $argv
  gh status
end
