import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../constants/constants.dart';
import '../blocs/blocs.dart';
import '../widgets/error_dialog.dart';
import 'search_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _city;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Home',
        style: TextStyle(fontFamily: 'Axiforma'),),
        backgroundColor: Colors.purple.shade700,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              _city = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SearchPage();
                }),
              );
              print('city: $_city');
              if (_city != null) {
                context
                    .read<WeatherBloc>()
                    .add(FetchWeatherEvent(city: _city!));
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SettingsPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Container(child: _showWeather(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade700, Colors.deepPurpleAccent.shade700],),
  ),
      ),
    );
  }

  String showTemperature(double temperature) {
    final tempUnit = context.watch<TempSettingsBloc>().state.tempUnit;

    if (tempUnit == TempUnit.fahrenheit) {
      return ((temperature * 9 / 5) + 32).toStringAsFixed(2) + '℉';
    }
    return temperature.toStringAsFixed(2) + '℃';
  }

  Widget showIcon(String abbr) {
    return FadeInImage.assetNetwork(
      placeholder: 'assets/images/loading.gif',
      image: 'https://$kHost/static/img/weather/png/64/$abbr.png',
      width: 64,
      height: 64,
    );
  }

  Widget _showWeather() {
    return BlocConsumer<WeatherBloc, WeatherState>(
      listener: (context, state) {
        if (state.status == WeatherStatus.error) {
          errorDialog(context, state.error.errMsg);
        }
      },
      builder: (context, state) {
        if (state.status == WeatherStatus.initial) {
          return  Center(
              child: Text(
                'Select a city',
                style: TextStyle(fontSize: 20.0),
              ),
            );
          
        }

        if (state.status == WeatherStatus.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.status == WeatherStatus.error && state.weather.title == '') {
          return Center(
            child: Text(
               'Select a city',
                style: TextStyle(
                fontFamily: 'Axiforma',
                fontSize: 20.0,
                color: Colors.white),
            ),
          );
        }

        return  ListView(
            children: [
              
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:15,vertical: 100),
              child: GlassmorphicContainer(
                  
              height: 410,
              width: 400,
              borderRadius: 25,
              blur: 50,
              border: 2,
              linearGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                               Color(0xFFffffff).withOpacity(0.4),
                               Color(0xFFFFFFFF).withOpacity(0.05),
                              ],
                              stops: [
                                0.1,
                                1,
                              ]),
                          borderGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                             const Color(0xFFffffff).withOpacity(0.5),
                              const Color((0xFFFFFFFF)).withOpacity(0.5),
                            ],
                          ),
              child:Column(
                  children:[
                SizedBox(
                  height: MediaQuery.of(context).size.height / 13,
                ),
                Text(
                  state.weather.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Axiforma',
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  TimeOfDay.fromDateTime(state.weather.lastUpdated).format(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20.0,
                  fontFamily: 'Axiforma',),
                ),
                SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showTemperature(state.weather.theTemp),
                      style: TextStyle(
                        fontFamily: 'Axiforma',
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Column(
                      children: [
                        Text(
                          showTemperature(state.weather.maxTemp),
                          style: TextStyle(
                            fontFamily: 'Axiforma',
                            fontSize: 18.0),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          showTemperature(state.weather.minTemp),
                          style: TextStyle(
                            fontFamily: 'Axiforma',
                          fontSize: 18.0),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Spacer(),
                    showIcon(state.weather.weatherStateAbbr),
                    SizedBox(width: 20.0),
                    Text(
                      state.weather.weatherStateName,
                      style: TextStyle(fontFamily: 'Axiforma',
                      fontSize: 30.0),
                    ),
                    Spacer(),
                  ],
                ),
              ],
                ),
                ),
            ),
            ],
          );
        
      },
    );
  }
}
