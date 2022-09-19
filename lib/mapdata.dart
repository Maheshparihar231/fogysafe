// ignore_for_file: prefer_final_fields

class FeedbackForm {

  String _latitide;
  String _longitude;
  String _time;

  FeedbackForm(this._latitide, this._longitude, this._time);

  // Method to make GET parameters.
  String toParams() =>
      "?latitide=$_latitide&longitude=$_longitude&time=$_time";
}