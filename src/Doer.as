package {
	public class Doer {

		//misc
		public static function substitutes(variables:Vector.<String>, values:Vector.<Number>, string:String, variables2:Vector.<String>=null, values2:Vector.<Number>=null, logical:Boolean=false):String {
			var secondVarsExist:Boolean=(variables2!=null)&&(values2!=null);
			//order the arrays
			var order:Vector.<int>=new Vector.<int>();
			for (var n:int=0; n<variables.length; n++) {
				var ok:Boolean=true;
				//temporary variables override global varriables
				if (secondVarsExist) {
					if (variables2.indexOf(variables[n])!=-1) {
						ok=false;
					}
				}
				if (ok) {
					order.push(n);
				}
			}
			if (secondVarsExist) {
				for (n=0; n<variables2.length; n++) {
					//The reason for subtracting 1 is to ensure there is
					//only 1 value in order equal to 0 not two, because -0=0
					order.push(-1*n-1);
				}
			}
			var val:int;
			for (n=1; n<order.length; n++) {
				val=order[n];
				var nameLength:int;
				if (val<0&&secondVarsExist) {
					//get the right name
					nameLength=variables2[-1*val-1].length;
				} else {
					nameLength=variables[val].length;
				}
				for (var m:int=0; m<n; m++) {
					var counterNameLength:int;
					if (order[m]<0&&secondVarsExist) {
						counterNameLength=variables2[-1*order[m]-1].length;
					} else {
						counterNameLength=variables[order[m]].length;
					}
					if (nameLength>counterNameLength) {
						break;
					}
				}
				if (m!=n) {
					order.splice(n,1);
					order.splice(m,0,val);
				}
			}
			for (n=0; n<order.length; n++) {
				var varName:String;
				var varVal:Number;
				val=order[n];
				if (val<0&&secondVarsExist) {
					varName=variables2[-1*val-1];
					varVal=values2[-1*val-1];
				} else {
					varName=variables[val];
					varVal=values[val];
				}
				string=substitute(varName,varVal.toString(),string,logical);
			}
			return string;
		}

		public static function substitute(variable:String, equals:String, string:String, logical:Boolean=false):String {
			equals="("+equals+")";
			var exp:RegExp=new RegExp("(^"+variable+"$)|(^"+variable+"[^a-z])|([^a-z]"+variable+"$)|([^a-z]"+variable+"[^a-z])","mi");
			var matches:Array=string.match(exp);
			if (matches!=null) {
				var count:int=0;
				while (matches!=null) {
					var match:String=matches[0].toString();
					var ind:int=string.indexOf(match);
					if (match.length==variable.length) {
						//string=string.replace(exp,equals);
						string=string.substr(0,ind)+equals+string.substr(ind+variable.length);
					} else if (match.length==(variable.length+2)) {
						//string=string.replace(exp,match.substr(0,1)+equals+match.substr(1+variable.length,1));
						string=string.substr(0,ind+1)+equals+string.substr(ind+variable.length+1);
					} else if (match.length==(variable.length+1)) {
						var nd:int=match.indexOf(variable);
						if (nd==0) {
							//string=string.replace(exp,equals+match.substr(variable.length,1));
							string=equals+string.substr(variable.length);
						} else {
							//string=string.replace(exp,match.substr(0,1)+equals);
							string=string.substr(0,nd+ind)+equals;
						}
					} else {
						trace("Big bad error: "+variable.length+" "+match.length);
					}
					
					matches=string.match(exp);

					count++;
					if (count>10000) {
						break;
					}
				}
			}
			return string;
		}

		//doBooleanAlgebra
		public static function doBooleanAlgebraGivens(variables:Vector.<String>, values:Vector.<Number>, string:String, variables2:Vector.<String>=null, values2:Vector.<Number>=null):Boolean {
			return doBooleanAlgebra(substitutes(variables, values, string, variables2, values2,true));
		}

		public static function doBooleanAlgebraGiven(variable:String, equals:String, string:String):Boolean {
			return doBooleanAlgebra(substitute(variable, equals, string,true));
		}

		public static function doBooleanAlgebra(string:String):Boolean {
			//trace(string);
			var left:String;
			var right:String;
			var openParenIndex:int=string.indexOf("(");
			var closeParenIndex:int=string.indexOf(")");
			var ok:Boolean=false;
			if (openParenIndex!=-1&&closeParenIndex!=-1) {
				if (hasBooleanOperator(string.substr(openParenIndex+1,closeParenIndex-openParenIndex-1))) {
					ok=true;
				}
			}
			if (ok) {
				if (openParenIndex<closeParenIndex) {
					var str:String;
					return doBooleanAlgebra(string.substr(0,openParenIndex)+doBooleanAlgebra(string.substr(openParenIndex+1, closeParenIndex-openParenIndex-1)).toString()+string.substr(closeParenIndex+1));
				} else {
					trace("Malformed boolean statement.");
					return false;
				}
			} else {
				var orIndex:int=string.indexOf("||");
				var andIndex:int=string.indexOf("&&");
				var equalIndex:int=string.indexOf("==");
				var notEqualIndex:int=string.indexOf("!=");
				var smallerThanOrEqualToIndex:int=string.indexOf("<=");
				var greaterThanOrEqualToIndex:int=string.indexOf(">=");
				var smallerThanIndex:int=string.indexOf("<");
				var greaterThanIndex:int=string.indexOf(">");
				var notIndex:int=string.indexOf("!");

				if (orIndex!=-1) {
					left=string.substr(0,orIndex);
					right=string.substr(orIndex+2);
					return doBooleanAlgebra(left)||doBooleanAlgebra(right);
				} else if (andIndex!=-1) {
					left=string.substr(0,andIndex);
					right=string.substr(andIndex+2);
					return doBooleanAlgebra(left)&&doBooleanAlgebra(right);
				} else if (notIndex!=-1&&notEqualIndex!=notIndex) {
					left=string.substr(0,notIndex);
					right=string.substr(notIndex+1);
					return doBooleanAlgebra(left+(!doBooleanAlgebra(right)).toString());
				} else if (equalIndex!=-1) {
					left=string.substr(0,equalIndex);
					right=string.substr(equalIndex+2);
					if (hasBooleanOperator(left)||hasBooleanOperator(right)||isBoolean(left)||isBoolean(right)) {
						return doBooleanAlgebra(left)==doBooleanAlgebra(right);
					} else {
						return doMath(left)==doMath(right);
					}
				} else if (notEqualIndex!=-1) {
					left=string.substr(0,notEqualIndex);
					right=string.substr(notEqualIndex+2);
					if (hasBooleanOperator(left)||hasBooleanOperator(right)||isBoolean(left)||isBoolean(right)) {
						return doBooleanAlgebra(left)!=doBooleanAlgebra(right);
					} else {
						return doMath(left)!=doMath(right);
					}
				} else if (smallerThanOrEqualToIndex!=-1) {
					left=string.substr(0,smallerThanOrEqualToIndex);
					right=string.substr(smallerThanOrEqualToIndex+2);
					return doMath(left)<=doMath(right);
				} else if (greaterThanOrEqualToIndex!=-1) {
					left=string.substr(0,greaterThanOrEqualToIndex);
					right=string.substr(greaterThanOrEqualToIndex+2);
					//trace(left+"->"+doMath(left)+"   "+right+"->"+doMath(right));

					return doMath(left)>=doMath(right);

				} else if (smallerThanIndex!=-1) {
					left=string.substr(0,smallerThanIndex);
					right=string.substr(smallerThanIndex+1);
					return doMath(left)<doMath(right);
				} else if (greaterThanIndex!=-1) {
					left=string.substr(0,greaterThanIndex);
					right=string.substr(greaterThanIndex+1);
					return doMath(left)>doMath(right);
				} else {
					if (string=="true") {
						return true;
					} else {
						return false;
					}
				}
			}
		}

		public static function hasBooleanOperator(string:String):Boolean {
			var orIndex:int=string.indexOf("||");
			var andIndex:int=string.indexOf("&&");
			var equalIndex:int=string.indexOf("==");
			var notEqualIndex:int=string.indexOf("!=");
			var smallerThanOrEqualToIndex:int=string.indexOf("<=");
			var greaterThanOrEqualToIndex:int=string.indexOf(">=");
			var smallerThanIndex:int=string.indexOf("<");
			var greaterThanIndex:int=string.indexOf(">");
			var notIndex:int=string.indexOf("!");
			if (orIndex!=-1||andIndex!=-1||equalIndex!=-1||notEqualIndex!=-1||smallerThanOrEqualToIndex!=-1||
			greaterThanOrEqualToIndex!=-1||smallerThanIndex!=-1||greaterThanIndex!=-1||notIndex!=-1) {
				return true;
			} else {
				return false;
			}
		}

		public static function isBoolean(string:String):Boolean {
			if (string=="true"||string=="false") {
				return true;
			} else {
				return false;
			}
		}

		//doMath
		public static function doMathGivens(variables:Vector.<String>, values:Vector.<Number>, string:String, variables2:Vector.<String>=null, values2:Vector.<Number>=null):Number {
			return doMath(substitutes(variables, values, string, variables2, values2,false));
		}

		public static function doMathGiven(variable:String, equals:String, string:String):Number {
			return doMath(substitute(variable, equals, string,false));
		}

		public static function doLanguageMath(string:String):Number {
			trace("Initial: "+string);
			//constants
			string=string.replace(/trillion/gi,"*1000000000000");
			string=string.replace(/billion/gi,"*1000000000");
			string=string.replace(/million/gi,"*1000000");
			string=string.replace(/(grand|thousand|k)/gi,"*1000");
			string=string.replace(/hundred/gi,"*100");
			string=string.replace(/score/gi,"*20");
			string=string.replace(/dozen/gi,"*12");
			string=string.replace(/tripplet/gi,"*3");
			string=string.replace(/(pair|couple)/gi,"*2");
			string=string.replace(/pi/gi,"3.141592653589793");

			//operations
			string=string.replace(/times/gi,"*");
			string=string.replace(/plus/gi,"+");
			string=string.replace(/minus/gi,"-");
			string=string.replace(/(divided\sby|over)/gi,"/");
			string=string.replace(/(to\sthe\spower\sof)/gi,"^");

			trace("Final: "+string);
			return doMath(string);
		}

		public static function doMath(string:String):Number {
			string=string.replace(/\s/g,"");
			//trace(string);
			var last:String;
			var openParIndex:int=string.indexOf("(");
			var closeParIndex:int=string.indexOf(")");
			if (openParIndex!=-1&&closeParIndex!=-1) {
				//parenthases
				var before:String=string.substr(0,openParIndex);
				var after:String=string.substr(closeParIndex+1);
				var between:String=string.substr(openParIndex+1,closeParIndex-openParIndex-1);
				var type:int=0;
				while (between.indexOf("(")!=-1) {
					openParIndex+=between.indexOf("(")+1;
					before=string.substr(0,openParIndex);
					after=string.substr(closeParIndex+1);
					between=string.substr(openParIndex+1,closeParIndex-openParIndex-1);
				}
				if (before!="") {
					var func:String;
					if (before.length>=4) {
						func=before.substr(before.length-4);
						if (func=="asin") {
							type=5;
						} else if (func=="acos") {
							type=6;
						} else if (func=="atan") {
							type=7;
						}
						if (type!=0) {
							before=before.substr(0,before.length-4);
						}
					}
					if (before.length>=3) {
						func=before.substr(before.length-3);
						if (func=="sin") {
							type=1;
						} else if (func=="cos") {
							type=2;
						} else if (func=="tan") {
							type=3;
						} else if (func=="log") {
							type=4;
						} else if (func=="abs") {
							type=8;
						}
						if (type!=0) {
							before=before.substr(0,before.length-3);
						}
					}
					if (before!="") {
						last=before.substr(before.length-1);
						if (last=="+"||last=="-"||last=="/"||last=="*"||last=="^"||last=="%"||last=="(") {
						} else {
							before=before+"*";
						}
					}
				}
				if (after!="") {
					last=after.substr(0,1);
					if (last=="+"||last=="-"||last=="/"||last=="*"||last=="^"||last=="%"||last==")") {
					} else {
						after="*"+after;
					}
				}
				if (type==1) {
					//sin
					return doMath(before+Math.sin(doMath(between))+after);
				} else if (type==2) {
					//cosine
					return doMath(before+Math.cos(doMath(between))+after);
				} else if (type==3) {
					//tangent
					return doMath(before+Math.tan(doMath(between))+after);
				} else if (type==4) {
					//natural log
					return doMath(before+Math.log(doMath(between))+after);
				} else if (type==5) {
					//inverse sin
					return doMath(before+Math.asin(doMath(between))+after);
				} else if (type==6) {
					//inverse cosine
					return doMath(before+Math.acos(doMath(between))+after);
				} else if (type==7) {
					//inverse tangent
					return doMath(before+Math.atan(doMath(between))+after);
				} else if (type==8) {
					//inverse tangent
					return doMath(before+Math.abs(doMath(between))+after);
				} else {
					//parenthases
					var bet:Number=doMath(between);
					var bets:String;
					if (bet<0) {
						bets="~"+Math.abs(bet).toString();
					} else {
						bets=bet.toString();
					}
					return doMath(before+bets+after);
				}
			} else {
				var addIndex:int=string.lastIndexOf("+");
				var subIndex:int=string.lastIndexOf("-");
				//addition must occur before subtraction
				//to avoid x+y/-z being treated as (x+y)/-z
				if (addIndex!=-1&&(addIndex>subIndex||subIndex==-1)) {
					//additon
					last=string.substr(addIndex-1,1);
					if (last=="+"||last=="-"||last=="/"||last=="*"||last=="^"||last=="%") {
						return doMath(string.substr(0, addIndex)+string.substr(addIndex+1));
					} else {
						return doMath(string.substr(0, addIndex))+doMath(string.substr(addIndex+1));
					}
				} else {
					if (subIndex!=-1) {
						//subtraction
						//and dealing with negatives #s
						var bigger:String=string.substr(0,subIndex);
						if (bigger.length==0) {
							return -1*doMath(string.substr(subIndex+1));
							//return doMath("~"+string.substr(subIndex+1));
						} else {
							last=bigger.substr(bigger.length-1);
							if (last=="+"||last=="-"||last=="/"||last=="*"||last=="^"||last=="%") {
								return doMath(bigger+"~"+string.substr(subIndex+1));
							} else {
								return doMath(bigger)-doMath(string.substr(subIndex+1));
							}
						}
					} else {
						var timesIndex:int=string.lastIndexOf("*");
						var divideIndex:int=string.lastIndexOf("/");
						if (timesIndex!=-1&&(timesIndex>divideIndex||divideIndex==-1)) {
							//multiply
							return doMath(string.substr(0, timesIndex))*doMath(string.substr(timesIndex+1));
						} else {
							if (divideIndex!=-1) {
								//division
								return doMath(string.substr(0, divideIndex))/doMath(string.substr(divideIndex+1));
							} else {
								var modIndex:int=string.lastIndexOf("%");
								if (modIndex!=-1) {
									//remainder
									return doMath(string.substr(0, modIndex))%doMath(string.substr(modIndex+1));
								} else {
									//constant
									var carretIndex:int=string.lastIndexOf("^");
									if (carretIndex!=-1) {
										//powers
										return Math.pow(doMath(string.substr(0, carretIndex)),doMath(string.substr(carretIndex+1)));
									} else {
										//it's a constant
										string=string.replace(/\~/g,"-");
										string=string.replace(/[^0-9|\.|-]/g,"");
										while (string.indexOf("--")!=-1) {
											string=string.replace(/--/g,"");
										}
										var value:Number=parseFloat(string);
										if (isNaN(value)) {
											//to handle things like +4+3 or -8/2
											value=0;
										}
										//trace(": "+value);
										return value;
									}
								}
							}
						}
					}
				}
			}
		}

		//end of class
	}
}