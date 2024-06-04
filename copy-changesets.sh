# run from the terraform-aws-common-fate-deployment repo
cp ../teams/.changeset/*.md .changeset/
find .changeset -type f -name '*.md' | xargs sed -i '' -e 's/@common-fate\/teams/@common-fate\/terraform-aws-common-fate-deployment/g'