import sys
import re
from pathlib import Path
import matplotlib.pyplot as plt # type: ignore
import numpy as np

def plot(horizons, name1, name2, data1, data2):

    traffic_results = {
        name1: data1,
        name2: data2,
    }

    x = np.arange(len(horizons))  # the label locations
    width = 0.25  # the width of the bars
    multiplier = 0.5

    _, ax = plt.subplots(layout='constrained')

    for attribute, measurement in traffic_results.items():
        offset = width * multiplier
        ax.bar(x + offset, measurement, width, label=attribute)
        #ax.bar_label(rects, padding=2)
        multiplier += 1

    # Add some text for labels, title and custom x-axis tick labels, etc.
    ax.set_ylabel('PCUs')
    ax.set_xlabel('Horizon (# of instances)')
    #ax.set_title('Penguin attributes by species')
    ax.set_xticks(x + width, horizons)
    #ax.legend(loc='upper left',title='Encoding', ncols=2,alignment='left')
    ax.set_ylim(0, 50000)
    plt.legend(loc='upper left',title='Encoding')
    plt.savefig('plot/'+str(name1)+'.jpg',dpi=300)
    #plt.show()

def collect_data(file,target,name):
    
    horizon = []
    exp_data = []
    cli_data = []

    with open(file,'r') as f:
        for line in f:
            if line.find('clingcon') >= 0:
               data = re.search(r'\: \d+\.\d+',line).group()
               cli_data.append(float(data[2:]))
            elif line.find(str(target)) >= 0:
                 n_inst = re.search(r'\[\d\d?',line).group()
                 hrz = re.search(r'\(\d\d\d',line).group()
                 data = re.search(r'\: \d+\.\d+',line).group()
                 horizon.append(hrz[1:]+' ('+n_inst[1:]+')')
                 #horizon.append(hrz)
                 exp_data.append(float(data[2:]))
            if re.search(r'\-{10}',line) != None and len(exp_data) > 0:
               #print(exp_data)
               #print(cli_data)
               plot(horizon,target,'clingcon',exp_data,cli_data) if str(name) == "target" else \
               plot(horizon,name,'clingcon',exp_data,cli_data) 
               horizon.clear()
               cli_data.clear()
               exp_data.clear()
            elif re.search(r'\-{10}',line) != None and len(cli_data) > 0 and len(exp_data) == 0:
               cli_data.clear()
            
                
            
            
        
def main():
    if len(sys.argv) != 4:
       print("Missed: file target")
       sys.exit(1)
    file = Path(sys.argv[1])
    target = Path(sys.argv[2])
    name = Path(sys.argv[3]) 
    collect_data(file,target,name)

if __name__ == "__main__":
    main()