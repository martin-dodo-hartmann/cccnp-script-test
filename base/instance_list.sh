#!/usr/bin/env bash

# functions copied from https://github.com/jasperes/bash-yaml
parse_yaml() {
    local yaml_file=$1
    local prefix=$2
    local s
    local w
    local fs

    s='[[:space:]]*'
    w='[a-zA-Z0-9_.-]*'
    fs="$(echo @|tr @ '\034')"

    (
        sed -e '/- [^\“]'"[^\']"'.*: /s|\([ ]*\)- \([[:space:]]*\)|\1-\'$'\n''  \1\2|g' |

        sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
            -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
            -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
            -e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |

        awk -F"$fs" '{
            indent = length($1)/2;
            if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
            vname[indent] = $2;
            for (i in vname) {if (i > indent) {delete vname[i]}}
                if (length($3) > 0) {
                    vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
                    printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1],$3);
                }
            }' |

        sed -e 's/_=/+=/g' |

        awk 'BEGIN {
                FS="=";
                OFS="="
            }
            /(-|\.).*=/ {
                gsub("-|\\.", "_", $1)
            }
            { print }'
    ) < "$yaml_file"
}

create_variables() {
    local yaml_file="$1"
    local prefix="$2"
    eval "$(parse_yaml "$yaml_file" "$prefix")"
}

instances=$(kubectl get ecominstances -n default -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')

while read -r line; do
    rm temp.yaml> /dev/null
    kubectl get ecominstance $line -n default -o yaml >> temp.yaml

    create_variables "temp.yaml" ""

    # cut off quotes
    metadata_labels_instance=$(echo $metadata_labels_instance |cut -c2-4)

    # TODO build hostname
    JSON="${JSON}"'"'"${metadata_name}"'": {
        "nodename": "'"${metadata_name}"'",
        "hostname": "localhost",
        "username": "admin",
        "remotehost": "'"${metadata_labels_realm}"'-'"${metadata_labels_instance}"'.sandbox.play.dx.unified.demandware.net",
        "realm": "'"${metadata_labels_realm}"'",
        "instance": "'"${metadata_labels_instance}"'",
        "id": "'"${metadata_labels_id}"'",
        "type": "'"${metadata_labels_type}"'",
        "node-executor": "script-exec",
        "script-exec": "./home/rundeck/etc/scripts/git-sync/operations/echo.sh",
        "tags": "'"${metadata_labels_type}"','"${metadata_labels_realm}"'"
    },'
done <<< "$instances"

JSON=${JSON%?};

echo -e '{
    '"$JSON"'
}'
