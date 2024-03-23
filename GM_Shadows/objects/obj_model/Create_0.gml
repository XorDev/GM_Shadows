///@desc Initialize model

DotobjSetFlipTexcoordV(true);

model = DotobjModelRawLoad("GMshaders\\GMShaders.dat");
//DotobjTryCache("GMshaders\\GMShaders.obj");

model.Freeze();