<%@ page language = "java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
	</head>
	<body>
		<h1>환율 계산</h1>
		<br>
		<table>
			<tr>
				<td>
					<span>송금국가:
						<select name="sendingCountry" id="sendingCountry">
							<option value="USD">미국(USD)</option>
							<option value="AUD">호주(AUD)</option>
						</select>
					</span>
				</td>
			</tr>
			<tr>
				<td>
					<span>수취국가:
						<select name="receivingCountry" id="receivingCountry">
							<option value="KRW">한국(KRW)</option>
							<option value="JPY">일본(JPY)</option>
							<option value="PHP">필리핀(PHP)</option>
						</select>
					</span>
				</td>
			</tr>
			<tr>
				<td>
					<span>환율: </span><span id="tgtRate"></span>
				</td>
			</tr>
			<tr>
				<td>
					<span>송금액: <input type="text" id="remittanceAmount"></span><span id="sendingCountryUnit"></span>
				</td>
			</tr>
			<tr>
				<td>
					<button id="submit">Submit</button>
				</td>
			</tr>
			<tr>
				<td>
					<span id="submitResult"></span>
				</td>
			</tr>
	
		</table>
		
		<script>
		var exchangeRateArr = [];
		var sendingCountry = "";
		var receivingCountry = "";
		var tgtExRate = 0;

		$(document).ready(function() {
			getExchangeRateArr();
			
			$("#sendingCountry").change(function() {
				getCalTgt()
			});
			
			$('#receivingCountry').change(function() {
				getCalTgt();
			});
			
			$('#submit').click(function() {
				getRemittanceResult();
			});
			
			$('#remittanceAmount').keyup(function(event) {
	            var inputVal = $(this).val();
	            $(this).val(inputVal.replace(/[^0-9]/gi,''));
			}).focusout(function(e) {
				var inputVal = $(this).val();
			 	$(this).val(inputVal.replace(/[^0-9]/gi,''));
			})
		});
		
		function getExchangeRateArr() {
			$.ajax({
				type : "POST",
				url : "ajax/getExchangeRateArr.do",
				dataType : "json",
				data : {},
				success : function(respon) {
					exchangeRateArr = respon.data;

					getCalTgt();
				}
				
			})
		}
		
		function getCalTgt(){
			sendingCountry = $('#sendingCountry option:selected').val();
			receivingCountry = $('#receivingCountry option:selected').val();
			
			if(sendingCountry == "USD") {
				
				for(var idx in exchangeRateArr) {
					
					if(exchangeRateArr[idx].country == sendingCountry + receivingCountry) {
						tgtExRate = numberWithCommaPoint(Math.round(exchangeRateArr[idx].rate *100)/100);
						
						$('#tgtRate').html(tgtExRate + " " + receivingCountry + "/" + sendingCountry);
						$('#sendingCountryUnit').html(" " + sendingCountry);
						
						break;
					}
				}
			}
			else {
				var sendingCountryExRate;
				var receivingCountryExRate;
				
				for(var idx in exchangeRateArr) {
					
					if(exchangeRateArr[idx].country == "USD"+sendingCountry) {
						sendingCountryExRate = exchangeRateArr[idx].rate;
						
						break;
					}
				}
				
				for(var idx in exchangeRateArr) {
					
					if(exchangeRateArr[idx].country == "USD"+receivingCountry) {
						receivingCountryExRate = exchangeRateArr[idx].rate;
						
						break;
					}
				}
				
				tgtExRate = numberWithCommaPoint(Math.round(receivingCountryExRate/sendingCountryExRate *100)/100);
				
				$('#tgtRate').html(tgtExRate + " " + receivingCountry + "/" + sendingCountry);
				$('#sendingCountryUnit').html(" " + sendingCountry);
			}
			
		}
		
		function getRemittanceResult() {
			var insertAmount = parseFloat($('#remittanceAmount').val());
			var remittanceAmount;
			
			if(insertAmount == 0 || insertAmount > 10000 || insertAmount.toString() == "NaN"){
				alert("송금액이 바르지 않습니다.");
				
				return;
			}
			
			remittanceAmount = numberWithCommaPoint(insertAmount * removeComma(tgtExRate));
			
			$('#submitResult').html("수취금액은 " + remittanceAmount + " " + $('#receivingCountry option:selected').val() + " 입니다.");
		}
		
		// 콤마, 포인트 2자리 적용.
		function numberWithCommaPoint(float) {
			var str = float.toString();
			
			str = parseFloat(str).toFixed(2);
			str = numberWithComma(str);
			str = numberWithPoint(str);
			
			return str;
		}
		
		//천 단위 콤마
		function numberWithComma(float) {
		    var str = float.toString().split(".");

		    str[0] = str[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");

		    return str.join(".");
		}
		
		//끝 2자리 0
		function numberWithPoint(str) {
			
			if(str.includes(".") == false) {
				str += ".00";
			}
			else {
				
				if(str.split(".")[1].length < 2) {
					str += "0";
					
					if(str.split(".")[1].length < 2) {
						str += "0";
					}
				}
			}
			
			return str;
		}
		
		//콤마 제거
		function removeComma(str) {
			var f = parseFloat(str.replace(/,/g,""));

			return f;
		}

		</script>
	</body>
</html>