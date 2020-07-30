# MesCol

MesCol is a handle class which provides communication for CS-1000 (KONICA MINOLTA).


## Usage 

### Construct
You can specify the Port and BaudRate.  
`'COM1'` and `9600` are default value for them.  

```
mesCol = MesCol();
mesCol = MesCol('COM1');
mesCol = MesCol('COM1', 9600);
```


### Set Remote On

```
mesCol.SetRemoteOn();
```


### Set measurement parameters
See detail on the manual document.

```
mesCol.SetMesMode(1, 60.00);
```


### Measure
Excute measurement.  
Data will be stored in the machine after this process succeed.  

```
mesCol.StartMes();
```


### Get Data
You can obtain measured data in spectral or property format.  
You can excute one or both of them.  


```
colSpec = mesCol.GetColSpec(0);
colProp = mesCol.GetColProp(0);
```

`colSpec`       : is a numeric array correspond to 401 wavelength(lambda 380:1:780 nm)  
`colProp`       : is a cell array contains 11 properties (Le, Lv, X, Y, Z, x, y, u', v', T, duv)  

## Example

See also the example file.  
`Batch_MesCal_Measure.m`  


## CS-1000 (EOP/EOS)

See more detail on the manual document with the machine.  
https://www.konicaminolta.jp/instruments/support/discontinued_products/cs1000a/index.html
