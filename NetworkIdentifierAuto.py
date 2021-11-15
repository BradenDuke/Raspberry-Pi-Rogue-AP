import subprocess

def choose_network (security_type, available_networks):
    types_of_security = ["Open", "WPA2-Personal", "WPA2-Enterprise"]
    for i in range(0, len(types_of_security)):
        for ii in range(0, len(security_type)):
            if types_of_security[i] == security_type[ii]:
                return available_networks[ii]
    return available_networks[0]
            
def name_change(chosen_network, available_networks):
    changed_name = ""
    correct = True
    checker = ["Guest", "2GEXT", "5GEXT", "Wi-Fi", "Main"]
    for i in range(0, len(checker)): 
        if checker[i].upper() not in chosen_network.upper():
            changed_name = chosen_network + " " + checker[i]
            correct = True
            for ii in range(0, len(available_networks)):
                if checker[i].upper() in available_networks[ii].upper():
                    correct = False
            if correct:
                return changed_name
                

results = subprocess.check_output(["netsh", "wlan", "show", "networks"])
results = results.decode("ascii")
results = results.replace("\r","")
ls = results.split('\n')
ls = ls[4:]
ls = list(filter(("").__ne__, ls))
authentication = []
ssids = []
x = 0
while x < len(ls):
    if x % 4 == 0:
        if ls[x][9:] == "":
            ssids.append("Hidden Network")
        else:
            ssids.append(ls[x][9:])
    if (x-2) % 4 == 0:
        authentication.append(ls[x][30:])
    x += 1
chosen_network = choose_network(authentication, ssids)
new_name = name_change(chosen_network, ssids)
print (new_name)
