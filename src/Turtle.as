//deep
var turtleSpeed:Number=10;
var penDown:Boolean=true;
var drawColor:uint=0xffffff;
var drawAlpha:Number=1;

var variableValues:Vector.<Number>;
var variableNames:Vector.<String>;
var loopLineStart:Vector.<int>;
var loopLineEnd:Vector.<int>;
var loopDepth:Vector.<int>;


var functionLineStart:Vector.<int>;
var functionLineEnd:Vector.<int>;
var functionNames:Vector.<String>;
var functionLineCall:Vector.<int>;
var functionParamNames:Vector.<Vector.<String>>;
var functionCallValues:Vector.<Vector.<Number>>;
var functionCallNames:Vector.<Vector.<String>>;



//lines
var lines:Vector.<String>=new Vector.<String>();
var lineIndex:int=-1;
var linePhase:int=-1;

//core params
var fName:String;
var xStart:Number;
var yStart:Number;
var xEnd:Number;
var yEnd:Number;


resetButton.addEventListener(MouseEvent.CLICK, reset);
runButton.addEventListener(MouseEvent.CLICK, run);
loadExampleButton.addEventListener(MouseEvent.CLICK, loadExample);
saveButton.addEventListener(MouseEvent.CLICK, saveCode);
addEventListener(Event.ENTER_FRAME, loop);



function reset(...rest):void {
	codeField.editable=true;
	drawingArea.draw.graphics.clear();
	drawingArea.turtle.x=0;
	drawingArea.turtle.y=0;
	drawingArea.turtle.rotation=0;
	lineIndex=-1;
	linePhase=-1;
}

function run(...rest):void {
	if (codeField.text!=""&&codeField.editable) {
		var lins:Array=codeField.text.split(/\n|\r/);
		lines=new Vector.<String>();
		for each (var line:String in lins) {
			lines.push(line);
		}
		codeField.editable=false;
		lineIndex=0;
		variableValues=new Vector.<Number>();
		variableNames=new Vector.<String>();
		loopLineStart=new Vector.<int>();
		loopLineEnd=new Vector.<int>();
		loopDepth=new Vector.<int>();
		functionNames=new Vector.<String>();
		functionLineEnd=new Vector.<int>();
		functionLineStart=new Vector.<int>();
		functionLineCall=new Vector.<int>();
	    functionParamNames=new Vector.<Vector.<String>>();
		functionCallValues=new Vector.<Vector.<Number>>();
	 	functionCallNames=new Vector.<Vector.<String>>();
		penDown=true;
		drawColor=0xffffff;
	 	drawAlpha=1;
	}
}

function loop(event:Event):void {
	
	
	if (lineIndex!=-1) {		
		var ok:Boolean=false;
		if(linePhase==-1||linePhase==1){
			ok=true;
		}
		var count:int=0;
		while(true){
			if (lineIndex<lines.length) {
				if (linePhase==-1) {
					//start line
					startLine(lines[lineIndex]);
				} else if (linePhase==0) {
					//continue line
					continueLine(lines[lineIndex]);
				} else {
					//go run next line
					lineIndex++;
					linePhase=-1;
					//are we done the commands?
					if (lineIndex>=lines.length) {
						codeField.editable=true;
						lineIndex=-1;
					}
				}
			}else{
				//we are done the commands
				linePhase=-1;
				codeField.editable=true;
				lineIndex=-1;
			}
			if(!ok){
				break;
			}else if(linePhase==0||lineIndex==-1){
				break
			}
			count++;
			if(count==10000){
				codeField.editable=true;
				lineIndex=-1;
				break;
			}
		}
	}
}

function startLine(line:String):void {
	//trace(functionLineCall.length);
	//define common varriable names
	var index:int;
	var n:int;
	var m:int;
	var count:int;
	
	//parse meaning and begin tweening
	//step 1 find the parenthases
	var openParenIndex:int=line.indexOf("(");
	var closeParenIndex:int=line.lastIndexOf(")");
	//validate
	if (openParenIndex!=-1&&closeParenIndex!=-1&&openParenIndex<closeParenIndex) {
		
		//check function
		var functionName:String=line.substr(0,openParenIndex);
		//get parameters
		var parmString:String=line.substr(openParenIndex+1,(closeParenIndex-openParenIndex)-1);
		var functionParams:Vector.<String>=new Vector.<String>();
		var functionParas:Array=parmString.split(",");
		for each (var param:String in functionParas) {
			if(param.length!=0){
				functionParams.push(param);
			}
		}
		if (functionName!="") {
			
			//delcare frequently used vars
			var rotAngle:Number;
			var dis:Number;
			var nameIndex:int;
			//store name
			fName=functionName+"";
			if(functionName=="move") {
				if (functionParams.length==1) {
					dis=eVal(functionParams[0]);
					xStart=drawingArea.turtle.x;
					yStart=drawingArea.turtle.y;
					rotAngle=drawingArea.turtle.rotation/180*Math.PI;
					xEnd=xStart+Math.cos(rotAngle)*dis;
					yEnd=yStart+Math.sin(rotAngle)*dis;
					//move to next phase
					linePhase=0;
				} else {
					//skip uninterpretable line
					linePhase=1;
				}
			}else if(functionName=="teleport"){
				if(functionParams.length==2){
					if(penDown){
						drawingArea.turtle.x=eVal(functionParams[0]);
						drawingArea.turtle.y=eVal(functionParams[1]);
					}
					linePhase=1;
				}else{
					//skip uninterpretable line
					linePhase=1;
				}
			}else if(functionName=="drop"){
				if(functionParams.length==0){
					if(penDown){
						drawingArea.draw.graphics.beginFill(drawColor,drawAlpha);
						drawingArea.draw.graphics.drawCircle(drawingArea.turtle.x, drawingArea.turtle.y,2);
					}
					linePhase=1;
				}else{
					//skip uninterpretable line
					linePhase=1;
				}
			}else if (functionName=="turn") {
				if (functionParams.length==1) {
					dis=eVal(functionParams[0]);
					if(dis!=0){
						xStart=drawingArea.turtle.rotation;
						xEnd=xStart+dis;
						yStart=Math.ceil(Math.abs(dis)/turtleSpeed);
						yEnd=dis/Math.abs(dis);
						//move to next phase
						linePhase=0;
					}else{
						linePhase=1;
					}
				} else {
					//skip uninterpretable line
					linePhase=1;
				}
			}else if (functionName=="set") {
				if (functionParams.length==2) {
					if(functionLineCall.length==0){
						//set global varriable
						setVarriableValue(functionParams[0], functionParams[1]);
					}else{
						//set temporaray varriable
						setTempVarriableValue(functionParams[0], functionParams[1]);
					}
					//finish line
					linePhase=1;
				}else{
					//skip uninterpretable line
					linePhase=1;
				}
			}else if (functionName=="setGlobal") {
				if (functionParams.length==2) {
					//sets the global varriable
					setVarriableValue(functionParams[0], functionParams[1]);
					//finish line
					linePhase=1;
				}else{
					//skip uninterpretable line
					linePhase=1;
				}
			} else if (functionName=="penColor"){
				if (functionParams.length>=3&&functionParams.length<5) {
					//red green blue
					drawColor=(eVal(functionParams[0])<<16)+(eVal(functionParams[1])<<8)+eVal(functionParams[2]);
					if(functionParams.length==4){
						drawAlpha=eVal(functionParams[3])/255;
					}
					linePhase=1;
				}else{
					//skip uninterpretable line
					linePhase=1;
				}
			} else if (functionName=="penUp"){
				if (functionParams.length==0) {
					penDown=false;
					linePhase=1;
				}else{
					//skip uninterpretable line
					linePhase=1;
				}
			} else if (functionName=="penDown"){
				if (functionParams.length==0) {
					penDown=true;
					linePhase=1;
				}else{
					//skip uninterpretable line
					linePhase=1;
				}
			} else if (functionName=="if"){
				if (functionParams.length==1) {
					//
					if(eBool(functionParams[0])){//if(Doer.doBooleanAlgebraGivens(variableNames, variableValues, functionParams[0])){
						//we're good
						linePhase=1;
					}else{
						//we're skrewed
						linePhase=-1;
						count=1;
						for(n=lineIndex+1;n<lines.length;n++){
							if(lines[n].indexOf("end")!=-1){
							count--;
								if(count==0){
										break;
								}
							}else if(lines[n].indexOf("if")!=-1||lines[n].indexOf("while")!=-1||lines[n].indexOf("declare")!=-1){
								count++;
							}
						}
						lineIndex=n;
					}
				} else {
					//skip uninterpretable line
					linePhase=1;
				}
			} else if (functionName=="declare"){
				if (functionParams.length>=1) {
					var functionDecName:String=functionParams[0];
					count=1;
					for(n=lineIndex+1;n<lines.length;n++){
						if(lines[n].indexOf("end")!=-1){
							count--;
							if(count==0){
								break;
							}
						}else if(lines[n].indexOf("if")!=-1||lines[n].indexOf("while")!=-1||lines[n].indexOf("declare")!=-1){
							count++;
						}
					}
					index=functionNames.indexOf(functionDecName);
					var paramNames:Vector.<String>=new Vector.<String>();
					for(m=1;m<functionParams.length;m++){
						paramNames.push(functionParams[m].replace(" ",""));
					}
					if(index==-1){
						//declare for first time
						functionNames.push(functionDecName);
						functionLineStart.push(lineIndex+1);
						functionLineEnd.push(n);
						functionParamNames.push(paramNames);
					}else{
						//redeclare
						functionNames[index]=functionDecName;
						functionLineStart[index]=lineIndex+1;
						functionLineEnd[index]=n;
						functionParamNames[index]=paramNames;
					}
					lineIndex=n;
					linePhase=-1;
				}else{
					//skip uninterpretable line
					linePhase=1;
				}
			} else if (functionName=="while"){
				if (functionParams.length==1) {
					var newLoop:Boolean=true;//=(loopLineStart.indexOf(lineIndex)==-1);
					var depth:int=functionLineCall.length-1;
					for(m=0;m<loopLineStart.length;m++){
						if(loopDepth[m]==depth&&loopLineStart[m]==lineIndex){
							newLoop=false;
							break;
						}
					}
					count=1;
					if(newLoop){
						for(n=lineIndex+1;n<lines.length;n++){
							if(lines[n].indexOf("end")!=-1){
								count--;
								if(count==0){
									break;
								}
							}else if(lines[n].indexOf("if")!=-1||lines[n].indexOf("while")!=-1||lines[n].indexOf("declare")!=-1){
								count++;
							}
						}
					}
					if(!newLoop||count==0){
						if(eBool(functionParams[0])){// if(Doer.doBooleanAlgebraGivens(variableNames, variableValues, functionParams[0])){
							if(newLoop){
								loopLineStart.push(lineIndex);
								loopLineEnd.push(n);
								loopDepth.push(depth);
							}else{
								//skip uninterpretable line
								linePhase=1;
							}
						}else{
							if(newLoop){
								linePhase=-1;
								lineIndex=n;
							}else{
								//we're done
								linePhase=-1;
								for(m=loopLineStart.length-1;m>=0;m--){
									if(loopDepth[m]==depth&&loopLineStart[m]==lineIndex){
										break;
									}
								}
								index=m;//loopLineStart.indexOf(lineIndex);
								lineIndex=loopLineEnd[index]+1;
								loopLineStart.splice(index,1);
								loopLineEnd.splice(index,1);
								loopDepth.splice(index,1);
							}
						}
					}else{
						//skip uninterpretable line
					linePhase=1;
					}
				}else{
					//skip uninterpretable line
					linePhase=1;
				}
			} else if (functionName=="call"){
				if (functionParams.length>=1) {
					index=functionNames.indexOf(functionParams[0]);
					if(index!=-1){
						//this is a loop
						//loopLineStart.push(functionLineStart[index]);
						//loopLineEnd.push(functionLineEnd[index]);
						
						//calculate parameter values
						var calculatedParams:Vector.<Number>=new Vector.<Number>();
						for(m=1;m<functionParams.length&&((m-1)<functionParamNames[index].length);m++){
							calculatedParams.push(eVal(functionParams[m]));
						}
						
						//this is where the function started
						functionLineCall.push(lineIndex);
						
						//traceIndentedLine(""+functionLineCall[functionLineCall.length-1])
						
						//setup temporary varriables
						functionCallValues.push(new Vector.<Number>());
						functionCallNames.push(new Vector.<String>());
						
						//set parameters to calculated values
						for(m=1;m<functionParams.length&&((m-1)<functionParamNames[index].length);m++){
							//setVarriableValue(functionParamNames[index][m-1], functionParams[m]);
							//setTempVarriableValue(functionParamNames[index][m-1], functionParams[m]);
							setTempVarriableValue(functionParamNames[index][m-1], calculatedParams[m-1].toString());
						}
						
						
						lineIndex=functionLineStart[index];
						
						linePhase=-1;
					}else{
						//undeclared function
						linePhase=1;
					}
				}else{
					//skip uninterpretable line
					linePhase=1;
				}
			} else if (functionName=="end"){
				index=loopLineEnd.lastIndexOf(lineIndex);
				if(index!=-1){
					lineIndex=loopLineStart[index];
					linePhase=-1;
					//traceIndentedLine(""+lineIndex);
				}else if(functionLineEnd.indexOf(lineIndex)!=-1&&functionLineCall.length>0){
					if(functionLineCall.length>0){
						//remove function call
						index=functionLineCall.length-1;
						
						//traceIndentedLine("x"+functionLineCall[index]);
						
						lineIndex=functionLineCall[index]+1;
						
						functionLineCall.splice(index,1);
						functionCallValues.splice(index,1);
						functionCallNames.splice(index,1);
						
						linePhase=-1;
					}else{
						linePhase=-1;
					}
				}else{
					linePhase=1;
				}
			} else {
				//skip uninterpretable line
				linePhase=1;
			}
			//
			//stop listing function names
			//
		} else {
			//skip uninterpretable line
			linePhase=1;
		}
	} else {
		//skip uninterpretable line
		linePhase=1;
	}
}

function eVal(thing:String):Number{
	if(functionLineCall.length==0){
		return Doer.doMathGivens(variableNames, variableValues, thing);
		//return getNumericVal(thing);
	}else{
		return Doer.doMathGivens(variableNames, variableValues, thing, functionCallNames[functionLineCall.length-1], functionCallValues[functionLineCall.length-1]);
	}
}

function eBool(thing:String):Boolean{
	if(functionLineCall.length==0){
		return Doer.doBooleanAlgebraGivens(variableNames, variableValues, thing);
	}else{
		return Doer.doBooleanAlgebraGivens(variableNames, variableValues, thing, functionCallNames[functionLineCall.length-1], functionCallValues[functionLineCall.length-1]);
	}
}

function setVarriableValue(varriableName:String, varriableValue:String):void{
	var dis:Number=eVal(varriableValue);
	var nameIndex:int=variableNames.indexOf(varriableName);
	if(nameIndex==-1){
		variableNames.push(varriableName);
		variableValues[variableNames.length-1]=dis;
	}else{
		variableValues[nameIndex]=dis;
	}
}

function setTempVarriableValue(varriableName:String, varriableValue:String):void{
	if(functionLineCall.length!=0){
		var funcIndex:int=functionLineCall.length-1;
		var dis:Number=eVal(varriableValue);
		var nameIndex:int=functionCallNames[funcIndex].indexOf(varriableName);
		if(nameIndex==-1){
			functionCallNames[funcIndex].push(varriableName);
			functionCallValues[funcIndex][functionCallNames[funcIndex].length-1]=dis;
		}else{
				
			functionCallValues[funcIndex][nameIndex]=dis;
		}
	}
}

function continueLine(line:String):void {
	if(fName=="move"){
		if(penDown){
			drawingArea.draw.graphics.lineStyle(1,drawColor,drawAlpha);
			drawingArea.draw.graphics.moveTo(drawingArea.turtle.x, drawingArea.turtle.y);
		}
		var dx:Number=xEnd-drawingArea.turtle.x;
		var dy:Number=yEnd-drawingArea.turtle.y;
		var dis:Number=Math.sqrt(dx*dx+dy*dy);
		if(dis<=turtleSpeed){
			drawingArea.turtle.x=xEnd;
			drawingArea.turtle.y=yEnd;
			//finish line
			linePhase=1;
		}else{
			drawingArea.turtle.x+=dx/dis*turtleSpeed;
			drawingArea.turtle.y+=dy/dis*turtleSpeed;
		}
		if(penDown){
			drawingArea.draw.graphics.lineTo(drawingArea.turtle.x, drawingArea.turtle.y);
		}
	}else if(fName=="turn"){
		yStart--;
		if(yStart==0){
			drawingArea.turtle.rotation=xEnd;
			//finish line
			linePhase=1;
		}else{
			drawingArea.turtle.rotation+=turtleSpeed*yEnd;
		}
	}else{
		//skip uncontinuable line
		linePhase=1;
	}
	
}

function traceIndentedLine(line:String):void{
	var str:String="";
	for(var n:int=0;n<functionLineCall.length-1;n++){
		str+=" ";
	}
	trace(str+line);
}

function saveCode(event:MouseEvent):void{
	var fileRef:FileReference=new FileReference();
	fileRef.save(codeField.text,"code.txt");
}

function loadExample(event:MouseEvent):void{
	switch(sampleList.selectedLabel){
		case "Koch Shape":
			codeField.text=strKochShape;
			break;
		case "Polygon":
			codeField.text=strPolygon;
			break;
		case "Line Circle":
			codeField.text=strLineCircle;
			break;
		case "Spiral":
			codeField.text=strSpiral;
			break;
		case "Rainbow":
			codeField.text=strRainbow;
			break;
		case "Koch Snowflake":
			codeField.text=strKochSnowflake;
			break;
		case "Blank":
			codeField.text=strBlank;
			break;
	}
	
}

var strPolygon:String="declare(drawPolygon,sides,length)\n"+
"set(increment, 360/sides)\n"+
"set(x,0)\n"+
"while(x<sides)\n"+
"move(length)\n"+
"turn(increment)\n"+
"set(x,x+1)\n"+
"end()\n"+
"end()\n"+
"call(drawPolygon,12,30)";

var strLineCircle:String="set(pi,3.14)\n"+
"set(angle,0)\n"+
"set(dis, 100)\n"+
"while(angle<360)\n"+
"penUp()\n"+
"move(cos(angle/180*pi)*dis)\n"+
"turn(-90)\n"+
"move(sin(angle/180*pi)*dis)\n"+
"turn(-90-angle)\n"+
"penDown()\n"+
"move(dis)\n"+
"turn(-180+angle)\n"+
"set(angle,angle+5)\n"+
"end()\n";

var strSpiral:String="declare(drawSpiral,len)\n"+
"if(len>0)\n"+
"move(len)\n"+
"turn(15)\n"+
"call(drawSpiral,len-0.5)\n"+
"end()\n"+
"end()\n"+
"call(drawSpiral,29)";

var strRainbow:String="set(red,254)\n"+
"set(green,0)\n"+
"set(blue,0)\n"+
"set(stage,0)\n"+
"set(speed,20)\n"+
"set(count,0)\n"+
"while(red<255||blue>0)\n"+
"penColor(red,green,blue)\n"+
"move(100)\n"+
"set(count,count+1)\n"+
"teleport(0,count)\n"+
"if(stage==5)\n"+
"set(blue,blue-speed)\n"+
"if(blue<=0)\n"+
"set(blue,0)\n"+
"end()\n"+
"end()\n"+
"if(stage==4)\n"+
"set(red,red+speed)\n"+
"if(red>=255)\n"+
"set(red,255)\n"+
"set(stage,5)\n"+
"end()\n"+
"end()\n"+
"if(stage==3)\n"+
"set(green,green-speed)\n"+
"if(green<=0)\n"+
"set(green,0)\n"+
"set(stage,4)\n"+
"end()\n"+
"end()\n"+
"if(stage==2)\n"+
"set(blue,blue+speed)\n"+
"if(blue>=255)\n"+
"set(blue,255)\n"+
"set(stage,3)\n"+
"end()\n"+
"end()\n"+
"if(stage==1)\n"+
"set(red,red-speed)\n"+
"if(red<=0)\n"+
"set(red,0)\n"+
"set(stage,2)\n"+
"end()\n"+
"end()\n"+
"if(stage==0)\n"+
"set(green,green+speed)\n"+
"if(green>=255)\n"+
"set(green,255)\n"+
"set(stage,1)\n"+
"end()\n"+
"end()\n"+
"end()";


var strKochSnowflake:String="declare(kochsnowflake,len,recursion)\n"+
"call(kochline,len,recursion)\n"+
"turn(-120)\n"+
"call(kochline,len,recursion)\n"+
"turn(-120)\n"+
"call(kochline,len,recursion)\n"+
"turn(-120)\n"+
"end()\n"+
"declare(kochline,len,recursion)\n"+
"if(recursion==0)\n"+
"move(len)\n"+
"end()\n"+
"if(recursion!=0)\n"+
"call(kochline,len/3,recursion-1)\n"+
"turn(60)\n"+
"call(kochline,len/3,recursion-1)\n"+
"turn(-120)\n"+
"call(kochline,len/3,recursion-1)\n"+
"turn(60)\n"+
"call(kochline,len/3,recursion-1)\n"+
"end()\n"+
"end()\n"+
"call(kochsnowflake,200,3)\n";

var strKochShape:String="declare(kochshape,len,recursion, shapesides,fracsides)\n"+
"if(shapesides>2)\n"+
"set(turn, 180*(shapesides-2)/shapesides-180)\n"+
"set(n,0)\n"+
"while(n<shapesides)\n"+
"call(kochline,len,recursion,fracsides)\n"+
"turn(turn)\n"+
"set(n,n+1)\n"+
"end()\n"+
"end()\n"+
"end()\n"+
"declare(kochline,len,recursion,fracsides)\n"+
"if(recursion==0)\n"+
"move(len)\n"+
"end()\n"+
"if(recursion!=0)\n"+
"set(dis,len/3)\n"+
"set(next,recursion-1)\n"+
"set(turna, 180*(fracsides-2)/fracsides)\n"+
"set(turnb, turna-180)\n"+
"call(kochline,dis,next,fracsides)\n"+
"turn(turna)\n"+
"set(n,0)\n"+
"while(n<(fracsides-2))\n"+
"call(kochline,dis,next,fracsides)\n"+
"turn(turnb)\n"+
"set(n,n+1)\n"+
"end()\n"+
"call(kochline,dis,next,fracsides)\n"+
"turn(turna)\n"+
"call(kochline,dis,next,fracsides)\n"+
"end()\n"+
"end()\n"+
"call(kochshape,100,3,4,4)";

var strBlank:String="";

codeField.text=strKochShape;