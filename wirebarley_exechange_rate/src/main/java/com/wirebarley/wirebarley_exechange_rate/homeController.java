package com.wirebarley.wirebarley_exechange_rate;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

@Controller
public class homeController {
	private final String CURRENCY_URL = "http://www.apilayer.net/api/live?access_key=";
	private final String CURRENCY_KEY = "d584a71201ff8a983b3edea24f5e803c";
	
	@GetMapping("/")
	public String home() {

		return "home";
	}
	
	@RequestMapping("ajax/getExchangeRateArr.do")
	@ResponseBody
	public ModelMap getExchangeRateArr() {
		ModelMap model = new ModelMap();

		InputStream			  is	= null;
		ByteArrayOutputStream baos	= null;
	
		try {
			String currencyUrl = CURRENCY_URL+CURRENCY_KEY;
			
			URL url = new URL(currencyUrl);
			
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setConnectTimeout(1000 * 60 * 5);
			conn.setReadTimeout(1000 * 60 * 5);
			conn.setRequestMethod("GET");
			conn.setRequestProperty("Accept", "application/json");
			conn.setDoOutput(true);
			conn.setDoInput(true);
			
			String response = "";
			int responseCode = conn.getResponseCode();
			
			System.out.println("responseCode=" + responseCode);
			
			if(responseCode == HttpURLConnection.HTTP_OK) {
				is = conn.getInputStream();
				baos = new ByteArrayOutputStream();
				byte[] byteBuffer = new byte[1024];
				byte[] byteData = null;
				int nLength = 0;
				
				while((nLength = is.read(byteBuffer, 0, byteBuffer.length)) != -1) {
					baos.write(byteBuffer, 0, nLength);
				}
				
				byteData = baos.toByteArray();
				
				response = new String(byteData, "UTF-8");
				
				System.out.println("response : " + response);
				
				JsonParser parser = new JsonParser();
				
				JsonObject obj = (JsonObject) parser.parse(response);
								
				JsonElement je = obj.get("quotes");
				
				System.out.println("exchange rate : " + je);

				String data = "";
				
				data = je.toString();
				
				data = data.replace("\"", "");
				data = data.replace("{", "");
				data = data.replace("}", "");
				
				String[] dataList = data.split(",");
				
				ArrayList<Map<String, Object>> dataArr = new ArrayList<>();
				
				for(String e : dataList) {
					String country = e.split(":")[0];
					String rate = e.split(":")[1];
				
					Map<String, Object> temp = new HashMap<String, Object>();
					temp.put("country", country);
					temp.put("rate", rate);
					dataArr.add(temp);
				}
				
				model.addAttribute("data", dataArr);
				
				System.out.println("getData END");
			}
			
		}
		catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
		finally {
			try {
				if(is != null) {
					is.close();
				}
				
				if(baos != null) {
					baos.flush();
					baos.close();
				}
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}

		return model;
	}

}
