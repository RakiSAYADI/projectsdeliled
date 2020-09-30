package deliled.applications.android.dmx;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

public class Scan extends Activity {
    //private static final String TAG = Scan.class.getSimpleName();
    int IntCount = 0;
    EditText EnterPin;
    ImageView pin1, pin2, pin3, pin4;
    LinearLayout PinCode;
    Button PinVerify;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scan);
        pin1 = findViewById(R.id.imageview_circle1);
        pin2 = findViewById(R.id.imageview_circle2);
        pin3 = findViewById(R.id.imageview_circle3);
        pin4 = findViewById(R.id.imageview_circle4);

        EnterPin = findViewById(R.id.EditTextEnterPin);
        EnterPin.requestFocus();
        InputMethodManager inputMethodManager = (InputMethodManager) getBaseContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        inputMethodManager.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
        EnterPin.setInputType(InputType.TYPE_CLASS_NUMBER);
        EnterPin.setFocusableInTouchMode(true);

        PinCode = findViewById(R.id.PinCode);
        PinCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                InputMethodManager inputMethodManager = (InputMethodManager) getBaseContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                inputMethodManager.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
            }
        });

        EnterPin.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                IntCount = s.length();
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                IntCount = s.length();
            }

            @Override
            public void afterTextChanged(Editable s) {
                switch (IntCount) {
                    case 0:
                        pin1.setImageResource(R.drawable.circle_on);
                        pin2.setImageResource(R.drawable.circle_on);
                        pin3.setImageResource(R.drawable.circle_on);
                        pin4.setImageResource(R.drawable.circle_on);

                        break;
                    case 1:
                        pin1.setImageResource(R.drawable.circle_off);
                        pin2.setImageResource(R.drawable.circle_on);
                        pin3.setImageResource(R.drawable.circle_on);
                        pin4.setImageResource(R.drawable.circle_on);

                        break;
                    case 2:
                        pin1.setImageResource(R.drawable.circle_off);
                        pin2.setImageResource(R.drawable.circle_off);
                        pin3.setImageResource(R.drawable.circle_on);
                        pin4.setImageResource(R.drawable.circle_on);
                        break;
                    case 3:
                        pin1.setImageResource(R.drawable.circle_off);
                        pin2.setImageResource(R.drawable.circle_off);
                        pin3.setImageResource(R.drawable.circle_off);
                        pin4.setImageResource(R.drawable.circle_on);
                        break;
                    case 4:
                        pin1.setImageResource(R.drawable.circle_off);
                        pin2.setImageResource(R.drawable.circle_off);
                        pin3.setImageResource(R.drawable.circle_off);
                        pin4.setImageResource(R.drawable.circle_off);
                        break;
                }

            }
        });

        PinVerify = findViewById(R.id.ButtonPinAccess);
        PinVerify.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (EnterPin.getText().toString().equals("1234")) {
                    Toast.makeText(getBaseContext(), "Code valide !", Toast.LENGTH_LONG).show();
                    Intent intent1 = new Intent(getBaseContext(), Qrcode.class);
                    startActivity(intent1);
                } else {
                    Toast.makeText(getBaseContext(), "Code non valide !", Toast.LENGTH_LONG).show();
                }
            }
        });
    }

    @Override
    public void onBackPressed() {
        //super.onBackPressed();
        Intent a = new Intent(Intent.ACTION_MAIN);
        a.addCategory(Intent.CATEGORY_HOME);
        a.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(a);
    }
}
