GROUPDIR="imss_admin"

sed -i '/"worker_bin_path"/d' /central/groups/$GROUPDIR/$USER/software/cryosparc/cluster_info.json
sed -i '/"cache_path"/d' /central/groups/$GROUPDIR/$USER/software/cryosparc/cluster_info.json

sed -i '3i\ \ \ \ "worker_bin_path" : "/central/groups/'"$GROUPDIR"'/'"$USER"'/software/cryosparc/cryosparc_worker/bin/cryosparcw",' /central/groups/$GROUPDIR/$USER/software/cryosparc/cluster_info.json
sed -i '4i\ \ \ \ "cache_path" : "/central/scratchio/'"$USER"'",' /central/groups/$GROUPDIR/$USER/software/cryosparc/cluster_info.json

