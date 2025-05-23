import 'package:flutter/material.dart';

class WalletButtonBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  WalletButtonBox({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSendButton = label == 'Enviar';
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          color: isSendButton 
              ? Colors.green 
              : Colors.black,
          borderRadius: BorderRadius.circular(8.0),
          border: isSendButton 
              ? null 
              : Border.all(color: Colors.white, width: 1.0),
          boxShadow: [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x34000000),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 40.0,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: "roboto",
                fontWeight: FontWeight.w400,
                color: Colors.white,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
