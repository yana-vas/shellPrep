#!/bin/bash

java_options=""
jar_file=""
app_args=""
seen_jar_flag=0
seen_jar_file=0
for arg in "$@"; do
    if [[ $seen_jar_file -eq 1 ]]; then
        if [[ -z "$app_args" ]]; then
            app_args="$arg"
        else
            app_args="${app_args} ${arg}"
        fi
    elif [[ "$seen_jar_file" -eq 0 ]]; then
        if [[ "$arg" == "-jar" ]]; then
            seen_jar_flag=1
        elif [[ "$arg" == -D* ]]; then
            if [[ "$seen_jar_flag" -eq 1 ]]; then
                if [[ -z "$java_options" ]]; then
                    java_options="$arg"
                else
                    java_options="${java_options} $arg"
                fi
            fi
        elif [[ "$arg" == -* ]]; then
            if [[ -z "$java_options" ]]; then
                java_options="$arg"
            else
                java_options="${java_options} $arg"
            fi
        else
            [[ $seen_jar_flag -eq 1 ]] || continue
            jar_file="$arg"
            seen_jar_file=1
        fi
    fi
done
java $java_options -jar "$jar_file" $app_args
