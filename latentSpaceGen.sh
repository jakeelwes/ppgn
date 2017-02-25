#/bin/bash
#
# Anh Nguyen <anh.ng8@gmail.com>
# 2016

# Take in epsilon1
# if [ "$#" -ne "1" ]; then
#   echo "Provide epsilon1 e.g. 1e-5"
#   exit 1
# fi

opt_layer=fc6
act_layer=fc8

#PlacesCNN
output_dir="output"

# number=$(find ${output_dir} -type f -name '*.jpg' | wc -l)
number="${1}"

#list_units="170 53 55 83 100 58 68 69" #outdoors -sky field ice creek dessert
list_units="`expr $number \* 10` `expr $number \* 10 + 1` `expr $number \* 10 + 2` `expr $number \* 10 + 3` `expr $number \* 10 + 4` `expr $number \* 10 + 5` `expr $number \* 10 + 6` `expr $number \* 10 + 7` `expr $number \* 10 + 8` `expr $number \* 10 + 9`"
list_units="`expr $number \* 10` `expr $number \* 10 + 1` `expr $number \* 10 + 2`"
#list_units="8 9 84" #art

#CaffeNet

#list_units="861 999" - toilet
#list_units="508 527 590 620 681" - digital
# list_units="12 13 14 15 16 17 18 19 20 21 22 23 24 25" -birds

xy=0              # Spatial position for conv layers, for fc layers: xy = 0
n_iters=200       # For each unit, for N iterations
reset_every=0     # For diversity, reset the code to random every N iterations. 0 to disable resetting.
save_every=1      # Save a sample every N iterations
lr=1
lr_end=1          # Linearly decay toward this ending lr (e.g. for decaying toward 0, set lr_end = 1e-10)
threshold=0       # Filter out samples below this threshold e.g. 0.98

# -----------------------------------------------
# Multipliers in the update rule Eq.11 in the paper
# -----------------------------------------------
epsilon1=1e-1       # prior
epsilon2=1        # condition
epsilon3=1e-17    # noise
# -----------------------------------------------

output_dir="output"
init_file="${output_dir}/$(($number-1)).jpg"     # Start from a random code
# init_file="None"
# Condition net
# net_weights="nets/caffenet/bvlc_reference_caffenet.caffemodel"
# net_definition="nets/caffenet/caffenet.prototxt"

net_weights="nets/placesCNN/places205CNN_iter_300000.caffemodel"
net_definition="nets/placesCNN/places205CNN_deploy_updated.prototxt"


#-----------------------

# Make a list of units
needle=" "
n_units=$(grep -o "$needle" <<< "$list_units" | wc -l)
units=${list_units// /_}

# Output dir
# mkdir -p ${output_dir}


# Directory to store samples
if [ "${save_every}" -gt "0" ]; then
    sample_dir=outputAbstract/${number}
    rm -rf ${sample_dir}
    mkdir -p ${sample_dir}
fi

unit_pad=`printf "%04d" ${unit}`


for seed in {0..0}; do

    python ./sampling_class.py \
        --act_layer ${act_layer} \
        --opt_layer ${opt_layer} \
        --units ${units} \
        --xy ${xy} \
        --n_iters ${n_iters} \
        --save_every ${save_every} \
        --reset_every ${reset_every} \
        --lr ${lr} \
        --lr_end ${lr_end} \
        --seed ${seed} \
        --output_dir ${output_dir} \
        --init_file ${init_file} \
        --epsilon1 ${epsilon1} \
        --epsilon2 ${epsilon2} \
        --epsilon3 ${epsilon3} \
        --threshold ${threshold} \
        --write_labels \
        --net_weights ${net_weights} \
        --net_definition ${net_definition} \

    # Save the samples
    if [ "${save_every}" -gt "0" ]; then

        f_chain=${output_dir}/${number}.jpg

        # Make a montage of intermediate samples
        # echo "Making a collage..."
        # montage ${sample_dir}/*.jpg -tile 10x -geometry +1+1 ${f_chain}
        # readlink -f ${f_chain}

        # echo "Making a gif..."
        # convert ${sample_dir}/*.jpg -delay 5 -loop 0 ${f_chain}.gif
        # readlink -f ${f_chain}.gif
    fi
done
