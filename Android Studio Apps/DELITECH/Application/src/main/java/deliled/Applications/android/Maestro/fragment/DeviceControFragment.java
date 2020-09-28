package deliled.Applications.android.Maestro.fragment;

import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.CountDownTimer;
import androidx.fragment.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;
import androidx.core.graphics.ColorUtils;
import com.example.circulardialog.CDialog;
import com.example.circulardialog.extras.CDConstants;
import com.skydoves.colorpickerview.ColorEnvelope;
import com.skydoves.colorpickerview.ColorPickerView;
import com.skydoves.colorpickerview.listeners.ColorEnvelopeListener;
import com.skydoves.colorpickerview.listeners.ColorPickerViewListener;

import deliled.Applications.android.Maestro.R;

import static androidx.core.graphics.ColorUtils.colorToHSL;
import static deliled.Applications.android.Maestro.MainActivity.CHAR_WRITE_LUMINOSITY;
import static deliled.Applications.android.Maestro.MainActivity.DATA_READING;
import static deliled.Applications.android.Maestro.MainActivity.SERVICE_WRITE;
import static deliled.Applications.android.Maestro.MainActivity.Scene_state;
import static deliled.Applications.android.Maestro.MainActivity.Udata_als;
import static deliled.Applications.android.Maestro.MainActivity.Udata_aq_status;
import static deliled.Applications.android.Maestro.MainActivity.Udata_co2l;
import static deliled.Applications.android.Maestro.MainActivity.Udata_humidity;
import static deliled.Applications.android.Maestro.MainActivity.Udata_ldt;
import static deliled.Applications.android.Maestro.MainActivity.Udata_temp;
import static deliled.Applications.android.Maestro.MainActivity.Udata_tvoc;
import static deliled.Applications.android.Maestro.MainActivity.Zone_1;
import static deliled.Applications.android.Maestro.MainActivity.Zone_2;
import static deliled.Applications.android.Maestro.MainActivity.Zone_3;
import static deliled.Applications.android.Maestro.MainActivity.Zone_4;
import static deliled.Applications.android.Maestro.MainActivity.bleReadWrite;
import static deliled.Applications.android.Maestro.MainActivity.getDate;
import static deliled.Applications.android.Maestro.MainActivity.indice_confinent;
import static deliled.Applications.android.Maestro.MainActivity.mBluetoothLeService;
import static deliled.Applications.android.Maestro.MainActivity.mConnected;
import static deliled.Applications.android.Maestro.MainActivity.mGattCharacteristics;
import static deliled.Applications.android.Maestro.MainActivity.state;

public class DeviceControFragment extends Fragment {
    private BluetoothGattCharacteristic mNotifyCharacteristic;
    public Button infopop;
    private TextView tempe,lumx,humi,cox2,detecte,tvoc,ICONE;
    private String colors ="000000";
    public BluetoothGatt mBluetoothGatt;
    public double Temperature=0;
    public short  CO2 =0;
    public int Z1,Z2,Z3,Z4,z10v;
    public String SELECTION ="0";
    public Button vplus , vmoins , modes;

    private ColorPickerView colorPickerView;

    SeekBar luminos, WHITE,satur;
    ToggleButton Ch1,Ch2,Ch3,Ch4,volt;

    public boolean mode_expert_active=false;

    public static boolean Acceuil_isactive;

    View view;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.maestro_fragment, container, false);
        Acceuil_isactive=true;
        mode_expert_active = false;
        tempe = view.findViewById(R.id.tempvalue);
        lumx = view.findViewById(R.id.lumvalue);
        humi = view.findViewById(R.id.humvalue);
        cox2 = view.findViewById(R.id.co2value);
        tvoc = view.findViewById(R.id.TVOC);
        detecte = view.findViewById(R.id.detection);
        luminos = view.findViewById(R.id.seekBar);
        colorPickerView = view.findViewById(R.id.colorPickerView);
        Ch1 = view.findViewById(R.id.Chambre1);
        Ch2 = view.findViewById(R.id.Chambre2);
        Ch3 = view.findViewById(R.id.Chambre3);
        Ch4 = view.findViewById(R.id.Chambre4);
        infopop = view.findViewById(R.id.popup1);
        WHITE = view.findViewById(R.id.white);
        ICONE = view.findViewById(R.id.indice_icone);
        volt = view.findViewById(R.id.volt);
        satur = view.findViewById(R.id.saturation);
        colorPickerView.selectCenter();

        /*int radius = Math.abs((int)colorPickerView.getX()-(int)colorPickerView.getSelectorX());
        float[] hsv = new float[3];
        Color.colorToHSV(Color.rgb(255,0,0), hsv);
        double x = hsv[1] * Math.cos(Math.toRadians(hsv[0]));
        double y = hsv[1] * Math.sin(Math.toRadians(hsv[0]));
        int pointX = (int) ((x + 1) * radius);
        int pointY = (int) ((1 - y) * radius);
        Log.i("compter","raduis = "+radius+" pointX = "+pointX+" pointY = "+pointY);
        colorPickerView.setSelectorPoint(pointX, pointY);*/

        saturation();
        colorpiker();
        bar_lum();
        select_room();
        popup();
        white_bar();
        rename();
        Testing_our_DATA();
        DATA_READ.start();
        return view;
    }

    public CountDownTimer DATA_READ=new CountDownTimer(1000,100) {
        @Override
        public void onTick(long millisUntilFinished) {
            if((!DATA_READING)||(!Acceuil_isactive))
            {
                cancel();
            }
        }
        @Override
        public void onFinish() {
            Testing_our_DATA();
            Log.i("compter","reading the DATA !");
            start();
        }
    };

    @Override
    public void onResume() {
        super.onResume();
        Testing_our_DATA();
        Acceuil_isactive=true;
    }

    private void Testing_our_DATA()
    {
        if(Udata_aq_status==16)
        {
            cox2.setText("Calcul en cours");
            tvoc.setText("Calcul en cours");
        }else {
            cox2.setText(String.valueOf(Udata_co2l).concat(" ppm"));
            tvoc.setText(Udata_tvoc+" g/m³");
        }
        detecte.setText(getDate(Udata_ldt * 1000));
        Temperature = Udata_temp;tempe.setText(String.format("%1.1f °C",Udata_temp));
        humi.setText(String.format("%1.1f",Udata_humidity).concat(" %"));
        lumx.setText(String.valueOf(Udata_als).concat(" lx"));ICONE.setText(""+indice_confinent);
        //alert the data if it's not safe (CO2)
        Alert();
        //rename the zones
        rename();
    }

    int alert_dialog =0;

    public void Alert (){
        try {
        CO2=Udata_co2l;
        if (CO2 >= 2000)
        {
            cox2.setTextColor(getResources().getColor(R.color.Red));
            if (alert_dialog==0)
            {
                new CDialog(getContext()).createAlert("Niveau de CO2 élévé !",
                        CDConstants.ERROR,   // Type of dialog
                        CDConstants.LARGE)    //  size of dialog
                        .setAnimation(CDConstants.SCALE_FROM_TOP_TO_BOTTOM)
                        .setDuration(60000)   // in milliseconds
                        .setTextSize(CDConstants.NORMAL_TEXT_SIZE)
                        .show();
            }
            alert_dialog++;
            if (alert_dialog==60)
            {
                alert_dialog=0;
            }
        }
        if ((CO2 < 1999)&(CO2>1700))
        {
            cox2.setTextColor(getResources().getColor(R.color.Orange));
            alert_dialog=0;
        }
        if (CO2 <= 1699)
        {
            cox2.setTextColor(getResources().getColor(R.color.Green));
            alert_dialog=0;
        }
        }catch (IllegalStateException e)
        {
            e.printStackTrace();
        }
    }

    private void goToUrl(String url) {
        Uri uriUrl = Uri.parse(url);
        Intent launchBrowser = new Intent(Intent.ACTION_VIEW, uriUrl);
        startActivity(launchBrowser);
    }
    public void sending_on_off(ToggleButton tooglebutton,String sel)
    {
        String Power;
        if(Scene_state==1)
        {
            Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
        }else
        if (state==0)
        {
            if (mConnected) {
                if(tooglebutton.isChecked())
                {
                    Power= "{\"light\":[1,0,"+sel+"]}";
                }
                else
                {
                    Power = "{\"light\":[1,1,"+sel+"]}";
                }
                Boolean check;
                do {

                    check=writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY, Power);
                } while (!check);
            }
        }
        else
        {
            Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
        }
    }
    public void select_room()
    {
        Ch1.setText(Zone_1);
        Ch2.setText(Zone_2);
        Ch3.setText(Zone_3);
        Ch4.setText(Zone_4);
        volt.setText(R.string.volt);
        volt.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (volt.isChecked()){

                    z10v=1;
                    volt.setTextOn("0/10V");
                    volt.setTextColor(getResources().getColor(R.color.White));
                }else {
                    z10v=0;
                    volt.setTextOff("0/10V");
                    volt.setTextColor(getResources().getColor(R.color.White));
                }
                SELECTION =Integer.toString((z10v*16)+(Z4*8)+(Z3*4)+(Z2*2)+Z1, 16);
                sending_on_off(volt,"10");
            }
        });
        Ch1.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener(){
            @Override
            public void onCheckedChanged(CompoundButton buttonView,boolean isChecked){
                if (Ch1.isChecked()) {
                    Z1 =1;
                    Ch1.setTextOn(Zone_1);
                    Ch1.setTextColor(getResources().getColor(R.color.White));
                } else {
                    Z1=0;
                    Ch1.setTextOff(Zone_1);
                    Ch1.setTextColor(getResources().getColor(R.color.White));
                }
                SELECTION =Integer.toString((z10v*16)+(Z4*8)+(Z3*4)+(Z2*2)+Z1, 16);
                sending_on_off(Ch1,"1");
            }
        });

        Ch2.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView,boolean isChecked) {
                if (Ch2.isChecked()) {
                    Z2 =1;
                    Ch2.setTextColor(getResources().getColor(R.color.White));
                    Ch2.setTextOn(Zone_2);
                } else {
                    Z2 =0;
                    Ch2.setTextOff(Zone_2);
                    Ch2.setTextColor(getResources().getColor(R.color.White));
                }
                SELECTION =Integer.toString((z10v*16)+(Z4*8)+(Z3*4)+(Z2*2)+Z1, 16);
                sending_on_off(Ch2,"2");
            }
        });
        Ch3.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView,boolean isChecked) {
                if (Ch3.isChecked()) {
                    Z3 =1;
                    Ch3.setTextColor(getResources().getColor(R.color.White));
                    Ch3.setTextOn(Zone_3);
                } else {
                    Z3 =0;
                    Ch3.setTextOff(Zone_3);
                    Ch3.setTextColor(getResources().getColor(R.color.White));
                }
                SELECTION =Integer.toString((z10v*16)+(Z4*8)+(Z3*4)+(Z2*2)+Z1, 16);
                sending_on_off(Ch3,"4");
            }
        });
        Ch4.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView,boolean isChecked) {
                if (Ch4.isChecked()) {
                    Z4 =1;
                    Ch4.setTextColor(getResources().getColor(R.color.White));
                    Ch4.setTextOn(Zone_4);
                } else {
                    Z4 =0;
                    Ch4.setTextOff(Zone_4);
                    Ch4.setTextColor(getResources().getColor(R.color.White));
                }
                SELECTION =Integer.toString((z10v*16)+(Z4*8)+(Z3*4)+(Z2*2)+Z1, 16);
                sending_on_off(Ch4,"8");
            }
        });
    }
    public void bar_lum ()
    {
        luminos.setProgress(100);
        luminos.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
        {
            int progressChangedValue=0;
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
            {
                if(Scene_state==1)
                {
                    Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
                }else
                if (state==0)
                {
                    progressChangedValue=progress;
                    String liminosity = "{\"light\":[7,"+progressChangedValue+","+SELECTION+"]}";
                    writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY,liminosity);
                }
                else
                {
                    Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar)
            {
                if(Scene_state==1)
                {
                    Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
                }else
                if (state==0)
                {
                    String liminosity = "{\"light\":[7," + progressChangedValue + "," + SELECTION + "]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, liminosity);
                }
                else
                {
                    Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    public void popup(){
        infopop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                goToUrl("https://delitech.eu/content/8-manuel-utilisation-lumiair-mobile");
            }
        });
    }

    public void lesmodes()
    {
        vplus.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String Vplus = "{\"light\":[4,1,"+SELECTION+"]}";
                writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY, Vplus);
            }
        });
        vmoins.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String Vmoins = "{\"light\":[4,0,"+SELECTION+"]}";
                writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY, Vmoins);
            }
        });
        modes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String modess = "{\"light\":[4,2,"+SELECTION+"]}";
                writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY, modess);
            }
        });
    }
    BluetoothGattCharacteristic charac_write;
    int charaProp_write;
    byte[] values_write;
    boolean write;
    public boolean writecharacteristic(int i,int j, String data){
        write=false;
        bleReadWrite=true;
        try {
            charac_write = mGattCharacteristics.get(i).get(j);
            charaProp_write = charac_write.getProperties();
            values_write = data.getBytes();
            charac_write.setValue(values_write);
            charac_write.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
            if ((charaProp_write | BluetoothGattCharacteristic.PROPERTY_WRITE) > 0) {
                if (mNotifyCharacteristic != null) {
                    mBluetoothLeService.setCharacteristicNotification(mNotifyCharacteristic, false);
                    mNotifyCharacteristic = null;
                }
                write = mBluetoothLeService.writeCharacteristic(charac_write);
                bleReadWrite = false;
            }
            if ((charaProp_write | BluetoothGattCharacteristic.PROPERTY_NOTIFY) > 0) {
                mNotifyCharacteristic = charac_write;
                mBluetoothLeService.setCharacteristicNotification(charac_write, true);
            }
        }catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        return write;
    }

    public long cppcount=0;

    public void colorpiker(){
        cppcount=0;
        colorPickerView.setColorListener(new ColorEnvelopeListener() {
            @Override
            public void onColorSelected(ColorEnvelope envelope, boolean fromUser) {
                View view_colors = view.findViewById(R.id.view);
                GradientDrawable shape =  new GradientDrawable();
                shape.setCornerRadius( 75 );
                shape.setColor(envelope.getColor());
                view_colors.setBackground(shape);
                //Log.i("hue","la valeur du couleur 0 : "+colorPickerView.getColorARGB(colorPickerView.getColor())[0]);
                //Log.i("hue","la valeur du couleur 1 : "+colorPickerView.getColorARGB(colorPickerView.getColor())[1]);
                //Log.i("hue","la valeur du couleur 2 : "+colorPickerView.getColorARGB(colorPickerView.getColor())[2]);
                //Log.i("hue","la valeur du couleur 3 : "+colorPickerView.getColorARGB(colorPickerView.getColor())[3]);

                //float [] HSL=new float[3];
                //colorToHSL(colorPickerView.getColor(),HSL);

                //colors = Integer.toString((int)HSL[0]);
                String col = colorPickerView.getColorEnvelope().getHexCode();
                colors = col.substring(2);

                //Log.i("hue","la valeur du HSL 0 : "+HSL[0]);
                //Log.i("hue","la valeur du HSL 1 : "+HSL[1]);
                //Log.i("hue","la valeur du HSL 2 : "+HSL[2]);

                //AmbiancesFragment.MightLight HUE;
                //HUE=RgbToHSL(colorPickerView.getColorARGB(colorPickerView.getColor()));

                //Log.i("hue","la valeur du HUE hue : "+HUE.Hue);
                //Log.i("hue","la valeur du HUE sat : "+HUE.Sat);
                //Log.i("hue","la valeur du HUE bri : "+HUE.Bri);

                if ((mBluetoothGatt.STATE_CONNECTED == 2) & (BluetoothGattCharacteristic.PROPERTY_WRITE > 0))
                {
                    cppcount++;
                    if (cppcount > 5)
                    {
                        if(Scene_state==1)
                        {
                            Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
                        }else
                        if (state==0)
                        {
                            send_colors(colors);
                        }
                        else
                        {
                            Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
                        }
                    }
                }
            }
        });
    }

    public void send_colors(String x) {
        String Couleurs = "{\"hue\":\""+x+"\",\"zone\":\""+SELECTION+"\"}";
        writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY, Couleurs);
    }

    public void rename()
    {
        Ch1.setText(Zone_1);
        Ch2.setText(Zone_2);
        Ch3.setText(Zone_3);
        Ch4.setText(Zone_4);
        Ch1.setTextOn(Zone_1);
        Ch2.setTextOn(Zone_2);
        Ch3.setTextOn(Zone_3);
        Ch4.setTextOn(Zone_4);
        Ch1.setTextOff(Zone_1);
        Ch2.setTextOff(Zone_2);
        Ch3.setTextOff(Zone_3);
        Ch4.setTextOff(Zone_4);
    }

    public void saturation(){
        //satur.setMax(360);
        satur.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int progressChangedValue=0;
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if(Scene_state==1)
                {
                    Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
                }else
                if (state==0)
                {
                    progressChangedValue=progress;
                    String saturation = "{\"light\":[9,"+progressChangedValue+","+SELECTION+"]}";
                    writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY,saturation);
                }
                else
                {
                    Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if(Scene_state==1)
                {
                    Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
                }else
                if (state==0)
                {
                    String saturation = "{\"light\":[9," + progressChangedValue + "," + SELECTION + "]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, saturation);
                }
                else
                {
                    Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
                }

            }
        });
    }

    public void white_bar()
    {
        WHITE.setProgress(50);
        WHITE.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int progressChangedValue=0;
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if(Scene_state==1)
                {
                    Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
                }else
                if (state==0)
                {
                    progressChangedValue=progress;
                    String blanche = "{\"light\":[8,"+progressChangedValue+","+SELECTION+"]}";
                    writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY,blanche);
                }
                else
                {
                    Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if(Scene_state==1)
                {
                    Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
                }else
                if (state==0)
                {
                    String blanche = "{\"light\":[8," + progressChangedValue + "," + SELECTION + "]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, blanche);
                }
                else
                {
                    Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
                }
            }
        });
    }
}
