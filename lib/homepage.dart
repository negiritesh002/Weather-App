import 'package:flutter/material.dart';
import 'package:weather/api.dart';
import 'package:weather/weathermodel.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  ApiResponse? response; 
  bool inprogress = false;
  String message = "Search for the location to get the weather data";
  var _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildSearchWidget(),
              const SizedBox(height: 20),
              if (inprogress)
                const CircularProgressIndicator()
              else
                Expanded(child: SingleChildScrollView(child: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: _buildWeatherWidget(),
                ))),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildSearchWidget() {
    return TextField(
      controller: _controller,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize :25,color: Colors.deepPurple,fontWeight: FontWeight.w500,letterSpacing: 2),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: _controller.clear,
          icon : Icon(Icons.clear)
        ),
        hintText: "Search any location",
        hintStyle: TextStyle(fontSize: 25,fontWeight: FontWeight.w600,letterSpacing: 2)
      ),
      onSubmitted: (value) {
        _getWeatherData(value);
      },
    );
  }

  Widget _buildWeatherWidget() {
    if (response == null) {
      return  Text(message);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.location_on,
                size: 50,
              ),
              Text(
                response?.location?.name ?? "",
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.w300),
              ),
              Text(
                response?.location?.country ?? "",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  (response?.current?.tempC.toString() ?? "") + "°c",
                  style: const TextStyle(
                      fontSize: 60, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                (response?.current?.condition?.text.toString() ?? ""),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Center(
            child: SizedBox(
              height: 200,
              child: Image.network(
                "https:${response?.current?.condition?.icon}"
                    .replaceAll("64x64", "128x128"),
                scale: 0.7,
              ),
            ),
          ),
          Card(
            elevation: 4,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _dataAndTitleWidget("Humidity",
                        response?.current?.humidity?.toString() ?? ""),
                    _dataAndTitleWidget("Wind Speed",
                        "${response?.current?.windKph?.toString() ?? ""}km/h")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _dataAndTitleWidget("UV",
                        response?.current?.uv?.toString() ?? ""),
                    _dataAndTitleWidget("Precipitation",
                        "${response?.current?.precipMm?.toString() ?? ""}mm")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _dataAndTitleWidget("Local Time",
                        response?.location?.localtime?.split(" ").last ?? ""),
                    _dataAndTitleWidget("Local Date",
                        response?.location?.localtime?.split(" ").first ?? ""),
                  ],
                )
              ],
            ),
          )
        ],
      );
    }
  }

  Widget _dataAndTitleWidget(String title, String data) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Text(
            data,
            style: const TextStyle(
              fontSize: 27,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(title,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ))
        ],
      ),
    );
  }

  _getWeatherData(String location) async {
    setState(() {
      inprogress = true;
    });
    try {
      response = await WeatherApi().getCurrentWeather(location);
    } catch (e) {
      setState(() {
        message = "failed to get weather";
        response = null;
      });
    } finally {
      setState(() {
        inprogress = false;
      });
    }
  }
}
