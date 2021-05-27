#This code inserts simulated masses into breast phantoms

import numpy as np 

path = '/home/nickneirotti/breastMass/Masses/571SlicePhantomMasses/pc_trinary_compressed_1683x2367x571_uint8.raw' #path to breast phantom 

#mass_path1 = '/home/nickneirotti/breastMass/Masses/RadDecTest/1mass_2040065257_381.raw'
#mass_path2 = '/home/nickneirotti/breastMass/Masses/RadDecTest/2mass_-895619926_410.raw'
#mass_path3 = '/home/nickneirotti/breastMass/Masses/RadDecTest/3mass_-958066282_409.raw'
#mass_path4 = '/home/nickneirotti/breastMass/Masses/RadDecTest/4mass_100018291_391.raw'
#mass_path5 = '/home/nickneirotti/breastMass/Masses/RadDecTest/5mass_-1127180784_353.raw'
#mass_path6 = '/home/nickneirotti/breastMass/Masses/RadDecTest/6mass_-63175471_413.raw'
#mass_path7 = '/home/nickneirotti/breastMass/Masses/RadDecTest/7mass_2104841405_407.raw'
#mass_path8 = '/home/nickneirotti/breastMass/Masses/RadDecTest/8mass_-1058350529_367.raw'
#mass_path9 = '/home/nickneirotti/breastMass/Masses/RadDecTest/9mass_-1032472937_458.raw'
#mass_path10 = '/home/nickneirotti/breastMass/Masses/RadDecTest/10mass_143001536_406.raw'
#mass_path11 = '/home/nickneirotti/breastMass/Masses/RadDecTest/11mass_-1196576451_413.raw'
#mass_path12 = '/home/nickneirotti/breastMass/Masses/RadDecTest/12mass_-563860795_372.raw'
#mass_path13 = '/home/nickneirotti/breastMass/Masses/RadDecTest/13mass_-1089656952_371.raw'
#mass_path14 = '/home/nickneirotti/breastMass/Masses/RadDecTest/14mass_-247560279_401.raw'
#mass_path15 = '/home/nickneirotti/breastMass/Masses/RadDecTest/15mass_-1298126617_378.raw'

mass_1 = '/home/nickneirotti/breastMass/Masses/571SlicePhantomMasses/1mass_1633754791_156.raw'

#mass_list = [mass_path1, mass_path2, mass_path3, mass_path4, mass_path5, mass_path6, #mass_path7, mass_path8, mass_path9, mass_path10, mass_path11, mass_path12, mass_path13, #mass_path14, mass_path15]

mass_list = [mass_1, mass_1, mass_1, mass_1, mass_1, mass_1, mass_1, mass_1, mass_1, mass_1, mass_1, mass_1, mass_1, mass_1, mass_1] 

#center of breast phantom
x_cent=1683//2
y_cent=2367//2
i_cent=571//2


change_y=300 #if inserting multiple masses inside the phantom, they will be placed 300 voxels apart 

num_mass=[len(mass_list)] 
mass_size = [156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156, 156] #Change to the size of the RAW file that contains the mass

output_phantom_name="SameSpicNabrMassInsert_1683x2367x571_array{}.raw"

change_x=200 #initial x-position of mass

#loading in breast phantom
print("Loading breast phantom")
bb = np.fromfile(path, dtype='uint8')
#Reshape size of phantom
bb=bb.reshape(571, 2367, 1683)
print("Loading masses")
z = 1
for (mass, s) in zip(mass_list, mass_size):    
    start_i=i_cent-s//2 #where mass first slice starts
    print("Inserting: " + mass) 
    cc = np.fromfile(mass, dtype='uint8')
    cc=cc.reshape(s, s, s)
    for num in num_mass: #Replaces phantom with set mass value of 200
	for i in range(s):
            for x in range(s):
                for y in range(s):
                    if cc[i,x,y] == 1:
                        bb[start_i+i, change_y+y, change_x+x]=200

	#Spacing of the masses
	if z <= 4:	        
	    change_y=change_y+400
	    z+=1
	elif z == 5:
	    change_y=change_y-1500
	    change_x=change_x+400
	    z+=1
	elif 6 <= z <= 9:
	    change_y=change_y+350
	    z+=1
	elif z == 10:
	    change_y=change_y-1225
	    change_x=change_x+350
	    z+=1	    
	elif 11 <= z <= 13:
	    change_y=change_y+350
	    z+=1
	else:
	    change_y=change_y-515
	    change_x=change_x+340
	    z+=1
	#elif 15 <= z <= 16:
	    #change_y=change_y+375
	    #z+=1
	#else:		
	    #change_y=change_y-375
	    #change_x=change_x+300

print("Saving phantom")
bb.tofile(output_phantom_name.format(0))
