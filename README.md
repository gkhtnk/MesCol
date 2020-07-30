# MesCol

MesCol is a handle class which provides communication for CS-1000 (KONICA MINOLTA).
This class is just a simple wrapper for COMMAND via RS-232.

## Usage 

See detail in the example file.
`Batch_MesCal_Measure.m`

Specify the Port and the BaudRate to construct the object.

```
mesCol = MesCol('COM1', 9600);
```

Set measurement parameters.

```
mesCol.SetRemoteOn();
mesCol.SetMesMode(1, 60.00);
```

Measurement

```
mesCol.StartMes();
colSpec = mesCol.GetColSpec(0);
colProp = mesCol.GetColProp(0);
```


## CS-1000 EOP

See more detail on the manual document with the product.
https://www.konicaminolta.jp/instruments/support/discontinued_products/cs1000a/index.html
