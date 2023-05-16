// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fluttertoast/fluttertoast.dart';

class OTPValidationPage extends StatefulWidget {
  @override
  _OTPValidationPageState createState() =>   _OTPValidationPageState();
}

class _OTPValidationPageState extends State<OTPValidationPage> {
  bool _isOTPValid = false;
  bool _is6thDigitEntered = false;
  List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String decryptedCode = '';

  Future<void> _callAPI() async {
    try {
      String url = 'https://otp-request.onrender.com/get-otp';
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      http.Response response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        String encryptedCode = json.decode(response.body)['code'];
        decryptedCode = _decryptCode(encryptedCode);
        _showToastMessage('Decrypted Code: $decryptedCode');
        _showOTPInputDialog();
      } else {
        throw Exception('Failed to fetch OTP');
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('Failed to fetch OTP');
    }
  }

  String _decryptCode(String encryptedCode) {
    String secretKey = '12345678123456781234567812345678';
    final key = encrypt.Key.fromUtf8(secretKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));
    final decrypted = encrypter.decrypt64(encryptedCode, iv: iv);
    print('Decrypted Code: $decrypted');
    return decrypted;
  }

  void _showOTPInputDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter OTP',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      width: 40.0,
                      height: 40.0,
                      child: TextField(
                        autofocus: true,
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        onChanged: (value) {
                          if (index < 5 && value.isNotEmpty) {
                            _focusNodes[index + 1].requestFocus();
                          }

                          if (index == 5) {
                            String enteredOTP = _getEnteredOTP();
                            bool isCorrect = enteredOTP == decryptedCode;
                            if (isCorrect) {
                              setState(() {
                                _isOTPValid = true;
                              });
                            } else {
                              setState(() {
                                _isOTPValid = false;
                              });
                            }
                          }
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isOTPValid ? Colors.green : Colors.black,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isOTPValid ? Colors.black : Colors.red,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isOTPValid ? Colors.black : Colors.red,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    _submitOTP();
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitOTP() {
    String enteredOTP = _getEnteredOTP();
    bool isCorrect = enteredOTP == decryptedCode;
    setState(() {
      _isOTPValid = isCorrect;
    });
    if (isCorrect) {
      _showToastMessage('Correct OTP');
    } else {
      _showToastMessage('Invalid OTP');
    }
  }

  String _getEnteredOTP() {
    String otp = '';
    for (var controller in _otpControllers) {
      otp += controller.text;
    }
    return otp;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Validation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _callAPI,
              child: Text('Get OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
