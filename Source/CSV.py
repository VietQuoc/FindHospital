import csv

def write_file(filename, *line):
    ''' Create new csv file with first data in A1 cell!
        Input path of filename. ex test_data/compliance/exp_filter_v2/filename.csv
    '''
        
    with open(filename, "a", newline='', encoding='utf-8') as file:
        for i in line:
            file.write(i+",")
    
        file.write("\n")
    file.close()
    
def read_data_file(name, index=0):
    your_list = []
    index = int(index)
    with open(name, mode='r', encoding="utf8") as csvfile:
        spamreader = csv.reader(csvfile, delimiter=',')
        for row in spamreader:
            your_list.append(row[index])
    return your_list

def work_csv_file(filename,mot,hai,ba,bon,nam,sau,bay,tam,chin,muoi,mmot,mhai,mba):
    ''' Create new csv file with first data in A1 cell!
        Input path of filename. ex test_data/compliance/exp_filter_v2/filename.csv
    '''
    
    csvfile = open(filename, "a", newline='', encoding='utf-8')
    writer = csv.writer(csvfile)
    writer.writerow([mot,hai,ba,bon,nam,sau,bay,tam,chin,muoi,mmot,mhai,mba])
    csvfile.close()

def read_file_as_string(name):
    with open(name, 'r', encoding="utf8") as myfile:
        data=myfile.read()
    return data

def write_file_text(name, text):
    with open(name, "a", encoding='utf-8') as file:
        file.write(text)
    file.close()
    