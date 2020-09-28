package deliled.Applications.android.Maestro.fragment;

import android.app.AlertDialog;
import android.bluetooth.BluetoothGattCharacteristic;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import androidx.fragment.app.Fragment;
import androidx.core.content.ContextCompat;

import android.os.CountDownTimer;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

import deliled.Applications.android.Maestro.R;

import static android.content.Context.MODE_PRIVATE;
import static deliled.Applications.android.Maestro.DeviceScanActivity.ACCESS;
import static deliled.Applications.android.Maestro.MainActivity.B1;
import static deliled.Applications.android.Maestro.MainActivity.B2;
import static deliled.Applications.android.Maestro.MainActivity.B3;
import static deliled.Applications.android.Maestro.MainActivity.B4;
import static deliled.Applications.android.Maestro.MainActivity.Blanche1;
import static deliled.Applications.android.Maestro.MainActivity.Blanche2;
import static deliled.Applications.android.Maestro.MainActivity.Blanche3;
import static deliled.Applications.android.Maestro.MainActivity.Blanche4;
import static deliled.Applications.android.Maestro.MainActivity.Favoris;
import static deliled.Applications.android.Maestro.MainActivity.L1;
import static deliled.Applications.android.Maestro.MainActivity.L2;
import static deliled.Applications.android.Maestro.MainActivity.L3;
import static deliled.Applications.android.Maestro.MainActivity.L4;
import static deliled.Applications.android.Maestro.MainActivity.R1;
import static deliled.Applications.android.Maestro.MainActivity.R2;
import static deliled.Applications.android.Maestro.MainActivity.R3;
import static deliled.Applications.android.Maestro.MainActivity.R4;
import static deliled.Applications.android.Maestro.MainActivity.Saving_scene;
import static deliled.Applications.android.Maestro.MainActivity.Scene_state;
import static deliled.Applications.android.Maestro.MainActivity.Udata_scene_number;
import static deliled.Applications.android.Maestro.MainActivity.V1;
import static deliled.Applications.android.Maestro.MainActivity.V2;
import static deliled.Applications.android.Maestro.MainActivity.V3;
import static deliled.Applications.android.Maestro.MainActivity.V4;
import static deliled.Applications.android.Maestro.MainActivity.Zo1;
import static deliled.Applications.android.Maestro.MainActivity.Zo2;
import static deliled.Applications.android.Maestro.MainActivity.Zo3;
import static deliled.Applications.android.Maestro.MainActivity.Zo4;
import static deliled.Applications.android.Maestro.MainActivity.Zone_1;
import static deliled.Applications.android.Maestro.MainActivity.Zone_2;
import static deliled.Applications.android.Maestro.MainActivity.Zone_3;
import static deliled.Applications.android.Maestro.MainActivity.Zone_4;
import static deliled.Applications.android.Maestro.MainActivity.stabilisation1;
import static deliled.Applications.android.Maestro.MainActivity.stabilisation2;
import static deliled.Applications.android.Maestro.MainActivity.stabilisation3;
import static deliled.Applications.android.Maestro.MainActivity.stabilisation4;
import static deliled.Applications.android.Maestro.MainActivity.bleReadWrite;
import static deliled.Applications.android.Maestro.MainActivity.couleur_name1;
import static deliled.Applications.android.Maestro.MainActivity.couleur_name2;
import static deliled.Applications.android.Maestro.MainActivity.couleur_name3;
import static deliled.Applications.android.Maestro.MainActivity.couleur_name4;
import static deliled.Applications.android.Maestro.MainActivity.mBluetoothLeService;
import static deliled.Applications.android.Maestro.MainActivity.mConnected;
import static deliled.Applications.android.Maestro.MainActivity.mGattCharacteristics;
import static deliled.Applications.android.Maestro.MainActivity.restart_Scenes;
import static deliled.Applications.android.Maestro.MainActivity.state;
import static deliled.Applications.android.Maestro.ajustement_luminosite.isHexNumber;
import static deliled.Applications.android.Maestro.fragment.AmbiancesFragment.white_selection;
import static deliled.Applications.android.Maestro.fragment.DeviceControFragment.Acceuil_isactive;

public class ScenesFragment extends Fragment {

    final int MAX_SCENES=40;
    final int MIN_SCENES=1;

    LinearLayout LayoutList,LayoutOption,LayoutZones_active;
    private LayoutInflater inflater_list;

    private CheckBox Scene_inf;

    //private ToggleButton Zone1,Zone2,Zone3,Zone4;
    private Button sceneHeureOn,sceneHeureOff;
    private Switch scene_on_off;

    //RelativeLayout.LayoutParams matchparam = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

    ArrayList<TextView> Ambiance_number = new ArrayList<>();
    ArrayList<TextView> Ambiance_name = new ArrayList<>();
    ArrayList<Spinner> Ambiance_duree = new ArrayList<>();
    ArrayList<Spinner> Ambiance_transition = new ArrayList<>();
    ArrayList<View> Ambiance_delete = new ArrayList<>();

    JSONObject Scènes;
    JSONArray  Scènes_state_zone;
    JSONObject Your_Scene;

    String Scenes_Zone;
    int infinity_scene;
    int SceneOnHeu,SceneOnMin;
    int SceneOffHeu,SceneOffMin;

    class View_Amb
    {
        TextView numero;
        View     view_display;
        TextView ambiance_name;
        Spinner  durree;
        Spinner  transition;
        View     delete;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view_Scenes;
        view_Scenes = inflater.inflate(R.layout.scenes_fragment, container, false);
        inflater_list=inflater;
        Acceuil_isactive=false;

        //Toast.makeText(getContext(),"Ce mode sera bientôt disponible !", Toast.LENGTH_LONG).show();
        //return view_Scenes;

        read_text_json();

        Button Add_Amb;

        RelativeLayout LayoutScenes;
        ScrollView scroll_list;

        RelativeLayout.LayoutParams config_LayoutOption = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        RelativeLayout.LayoutParams config_LayoutZones_active = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        RelativeLayout.LayoutParams config_scroll_list = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        LinearLayout.LayoutParams wrapparam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        LayoutScenes = new RelativeLayout(getContext());
        LayoutList = new LinearLayout(getContext());
        scroll_list = new ScrollView(getContext());
        LayoutOption = new LinearLayout(getContext());
        LayoutZones_active=new LinearLayout(getContext());

        LayoutOption.setId(View.generateViewId());
        LayoutZones_active.setId(View.generateViewId());

        LayoutList.setLayoutParams(wrapparam);

        config_LayoutZones_active.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        LayoutZones_active.setLayoutParams(config_LayoutZones_active);

        config_LayoutOption.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        LayoutOption.setLayoutParams(config_LayoutOption);
        config_scroll_list.addRule(RelativeLayout.ABOVE,LayoutOption.getId());
        config_scroll_list.addRule(RelativeLayout.BELOW,LayoutZones_active.getId());
        scroll_list.setLayoutParams(config_scroll_list);

        LayoutScenes.setLayoutParams(wrapparam);

        LayoutList.setOrientation(LinearLayout.VERTICAL);
        LayoutOption.setOrientation(LinearLayout.VERTICAL);
        LayoutZones_active.setOrientation(LinearLayout.VERTICAL);
        LayoutList.setGravity(Gravity.TOP);
        LayoutOption.setGravity(Gravity.CENTER);
        LayoutZones_active.setGravity(Gravity.CENTER);
        LayoutScenes.setGravity(Gravity.TOP);

        View view_sce_zone_act=inflater_list.inflate(R.layout.scenes_zone_active, null);

        //Zone1=view_sce_zone_act.findViewById(R.id.Zone_scene_1);
        //Zone2=view_sce_zone_act.findViewById(R.id.Zone_scene_2);
        //Zone3=view_sce_zone_act.findViewById(R.id.Zone_scene_3);
        //Zone4=view_sce_zone_act.findViewById(R.id.Zone_scene_4);
        sceneHeureOn=view_sce_zone_act.findViewById(R.id.scene_heure_on);
        sceneHeureOff=view_sce_zone_act.findViewById(R.id.scene_heure_off);
        scene_on_off=view_sce_zone_act.findViewById(R.id.switch_scenes);

        LayoutZones_active.addView(view_sce_zone_act);

        View view_sce_opt=inflater_list.inflate(R.layout.scene_option, null);

        Scene_inf=view_sce_opt.findViewById(R.id.Scene_infinti);
        Add_Amb=view_sce_opt.findViewById(R.id.add_Amb);

        LayoutOption.addView(view_sce_opt);

        reading_scene();

        //read_zones();

        if (restart_Scenes)
        {
            restart_Scenes=false;
        }

        sceneHeureOn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final LinearLayout.LayoutParams lparam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                LinearLayout layout = new LinearLayout(requireContext());
                layout.setOrientation(LinearLayout.HORIZONTAL);
                layout.setLayoutParams(lparam);
                layout.setGravity(Gravity.CENTER);
                ArrayAdapter<String> adapter = new ArrayAdapter<>(requireContext(), R.layout.spinner_item,getResources().getStringArray(R.array.heure));
                adapter.setDropDownViewResource(R.layout.drop_list_spinner);
                ArrayAdapter <String> adapter1 = new ArrayAdapter<>(requireContext(), R.layout.spinner_item,getResources().getStringArray(R.array.minute));
                adapter1.setDropDownViewResource(R.layout.drop_list_spinner);
                final Spinner temp_heure = new Spinner(requireContext());
                temp_heure.setAdapter(adapter);
                temp_heure.setSelection(SceneOnHeu);
                layout.addView(temp_heure);
                final TextView heure_min = new TextView(requireContext());
                String dot=" : ";
                heure_min.setText(dot);
                layout.addView(heure_min);
                final Spinner temp_minute = new Spinner(requireContext());
                temp_minute.setAdapter(adapter1);
                temp_minute.setSelection(SceneOnMin);
                layout.addView(temp_minute);
                final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
                builder.setMessage("Sélectionner l'heure de Debut :")
                        .setTitle("Réglages")
                        .setCancelable(true)
                        .setView(layout)
                        .setNegativeButton("Abandonner", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                dialog.cancel();
                            }
                        })
                        .setPositiveButton("Appliquer", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                SceneOnHeu=temp_heure.getSelectedItemPosition();
                                SceneOnMin=temp_minute.getSelectedItemPosition();
                                Saving_Scene();
                                dialog.cancel();
                            }
                        });
                final AlertDialog alert = builder.create();
                alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
                alert.show();
            }
        });

        sceneHeureOff.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final LinearLayout.LayoutParams lparam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                LinearLayout layout = new LinearLayout(requireContext());
                layout.setOrientation(LinearLayout.HORIZONTAL);
                layout.setLayoutParams(lparam);
                layout.setGravity(Gravity.CENTER);
                ArrayAdapter<String> adapter = new ArrayAdapter<>(requireContext(), R.layout.spinner_item,getResources().getStringArray(R.array.heure));
                adapter.setDropDownViewResource(R.layout.drop_list_spinner);
                ArrayAdapter <String> adapter1 = new ArrayAdapter<>(requireContext(), R.layout.spinner_item,getResources().getStringArray(R.array.minute));
                adapter1.setDropDownViewResource(R.layout.drop_list_spinner);
                final Spinner temp_heure = new Spinner(requireContext());
                temp_heure.setAdapter(adapter);
                temp_heure.setSelection(SceneOffHeu);
                layout.addView(temp_heure);
                final TextView heure_min = new TextView(requireContext());
                String dot=" : ";
                heure_min.setText(dot);
                layout.addView(heure_min);
                final Spinner temp_minute = new Spinner(requireContext());
                temp_minute.setAdapter(adapter1);
                temp_minute.setSelection(SceneOffMin);
                layout.addView(temp_minute);
                final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
                builder.setMessage("Sélectionner l'heure de Fin :")
                        .setTitle("Réglages")
                        .setCancelable(true)
                        .setView(layout)
                        .setNegativeButton("Abandonner", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                dialog.cancel();
                            }
                        })
                        .setPositiveButton("Appliquer", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                SceneOffHeu=temp_heure.getSelectedItemPosition();
                                SceneOffMin=temp_minute.getSelectedItemPosition();
                                Saving_Scene();
                                dialog.cancel();
                            }
                        });
                final AlertDialog alert = builder.create();
                alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
                alert.show();
            }
        });

        /*Zone1.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(Saving_scene)
                {
                    Saving_Scene();
                }
            }
        });
        Zone2.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(Saving_scene)
                {
                    Saving_Scene();
                }
            }
        });
        Zone3.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(Saving_scene)
                {
                    Saving_Scene();
                }
            }
        });
        Zone4.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(Saving_scene)
                {
                    Saving_Scene();
                }
            }
        });*/

        Scene_inf.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(Saving_scene)
                {
                    Saving_Scene();
                }
            }
        });

        Add_Amb.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
               Add_ambiance();
            }
        });
        scene_on_off.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(ACCESS)
                {
                    if (state==1)
                    {
                        final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
                        builder.setMessage("Vous devez être en mode « MANU » pour activer les scènes. Changer de mode ?")
                                .setTitle("Attention")
                                .setCancelable(true)
                                .setNegativeButton("NON", new DialogInterface.OnClickListener() {
                                    public void onClick(final DialogInterface dialog, final int id) {
                                        dialog.cancel();
                                    }
                                })
                                .setPositiveButton("OUI", new DialogInterface.OnClickListener() {
                                    public void onClick(final DialogInterface dialog, final int id) {
                                    scene_on_off.setChecked(true);
                                    if (mConnected) {
                                        boolean check;
                                        do {
                                            String switching = "{\"mode\":\"manu\"}";
                                            state = 0;
                                            check = writecharacteristic(3, 0, switching);
                                        }
                                        while (!check);
                                    }
                                    Saving_Scene();
                                    dialog.cancel();
                                }  });
                        final AlertDialog alert = builder.create();
                        alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
                        alert.show();
                    }else {
                        Saving_Scene();
                    }
                }else
                {
                    if (state==1)
                    {
                        final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
                        builder.setMessage("Pour activer les scenes il faut que tu connectes tent qu'adiministrateur !")
                                .setTitle("Information")
                                .setCancelable(true)
                                .setNeutralButton("OK", new DialogInterface.OnClickListener() {
                                    public void onClick(final DialogInterface dialog, final int id) {
                                        dialog.cancel();
                                    }
                                });
                        final AlertDialog alert = builder.create();
                        alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
                        alert.show();
                        scene_on_off.setChecked(false);
                    }
                }
                if(isChecked)
                {
                    scene_on_off.setText(getResources().getString(R.string.active));
                    Scene_state=1;
                }else {
                    scene_on_off.setText(getResources().getString(R.string.descative));
                    Scene_state=0;
                }
            }
        });

        scroll_list.addView(LayoutList);

        LayoutScenes.addView(LayoutZones_active);

        LayoutScenes.addView(scroll_list);

        LayoutScenes.addView(LayoutOption);

        if(Scene_state==1)
        {
            scene_on_off.setText(getResources().getString(R.string.active));
        }else {
            scene_on_off.setText(getResources().getString(R.string.descative));
        }

        Saving_Scene();

        Saving_scene=false;

        return LayoutScenes.getRootView();
    }

    private CountDownTimer Checking_scene_state= new CountDownTimer(1000,1000) {
        @Override
        public void onTick(long millisUntilFinished) {
            //Log.i("My App", "it's running on tick ");
        }
        @Override
        public void onFinish() {
            Log.i("My App", "it's running on finish ");
            for(int i=0;i<Ambiance_number.size();i++)
            {
                if(Udata_scene_number==i)
                {
                    Ambiance_number.get(i).setBackgroundColor(ContextCompat.getColor(getContext(),R.color.White));
                    Ambiance_number.get(i).setTextColor(ContextCompat.getColor(getContext(),R.color.Black));
                }else
                {
                    Ambiance_number.get(i).setBackgroundColor(ContextCompat.getColor(getContext(),R.color.fbutton_color_transparent));
                    Ambiance_number.get(i).setTextColor(ContextCompat.getColor(getContext(),R.color.White));
                }
            }
            start();
        }
    };

    @Override
    public void onPause()
    {
        super.onPause();
        Checking_scene_state.cancel();
    }

    @Override
    public void onResume()
    {
        super.onResume();
        Checking_scene_state.start();
    }

    public static String scene_default="{\"zone_act\":[0,\"0\",0,0,0,0],\"inf\":0,\"scenes\":{\"0\":[0,0,0],\"1\":[1,0,0],\"2\":[2,0,0],\"3\":[3,0,0]}}";

    public void reading_scene()
    {

        if (!fileExists(getContext(),"Scenes.txt"))
        {
            save("Scenes.txt",scene_default);
        }
        String le_scene=load("Scenes.txt");

        try
        {
            Scènes = new JSONObject(le_scene);
            infinity_scene=Scènes.getInt("inf");
            Scènes_state_zone=Scènes.getJSONArray("zone_act");
            //Scene_state=Scènes_state_zone.getInt(0);
            Scenes_Zone=Scènes_state_zone.getString(1);
            SceneOnHeu=Scènes_state_zone.getInt(2);
            SceneOnMin=Scènes_state_zone.getInt(3);
            SceneOffHeu=Scènes_state_zone.getInt(4);
            SceneOffMin=Scènes_state_zone.getInt(5);
            Your_Scene = Scènes.getJSONObject("scenes");
            String amb_name="";
            int number;
            for (int j=0;j<Your_Scene.names().length();j++)
            {
                number=Your_Scene.getJSONArray(String.valueOf(j)).getInt(0);
                switch (number)
                {
                    case 0:
                        amb_name=couleur_name1;
                        break;
                    case 1:
                        amb_name=couleur_name2;
                        break;
                    case 2:
                        amb_name=couleur_name3;
                        break;
                    case 3:
                        amb_name=couleur_name4;
                        break;
                }
                setting_Scenes(j,amb_name,Your_Scene.getJSONArray(String.valueOf(j)).getInt(1),Your_Scene.getJSONArray(String.valueOf(j)).getInt(2));
            }
            reading_zone_state();
        }
        catch (Throwable t)
        {
            Log.e("My App", "Could not parse malformed scenes "+Scènes.toString());
            save("Scenes.txt",scene_default);
            setting_Scenes(0,couleur_name1,0,0);
            setting_Scenes(1,couleur_name2,0,0);
            setting_Scenes(2,couleur_name3,0,0);
            setting_Scenes(3,couleur_name4,0,0);
        }
    }

    public void reading_zone_state()
    {
        if(infinity_scene==0)
        {
            Scene_inf.setChecked(false);
        }else
        {
            Scene_inf.setChecked(true);
        }
        if(!isHexNumber(Scenes_Zone))
        {
            Scenes_Zone="0";
        }
        /*int zone = Integer.parseInt(Scenes_Zone,16);
        int z4 = zone/8;
        int z3 = zone%8/4;
        int z2 = zone%4/2;
        int z1 = zone%2;
        if (z1==0){Zone1.setChecked(false);}else{Zone1.setChecked(true);}
        if (z2==0){Zone2.setChecked(false);}else{Zone2.setChecked(true);}
        if (z3==0){Zone3.setChecked(false);}else{Zone3.setChecked(true);}
        if (z4==0){Zone4.setChecked(false);}else{Zone4.setChecked(true);}*/
        if(Scene_state==0)
        {
            scene_on_off.setChecked(false);
            scene_on_off.setText(getResources().getString(R.string.active));
        }else
        {
            scene_on_off.setChecked(true);
            scene_on_off.setText(getResources().getString(R.string.descative));
        }
    }

    public void saving_zone_state()
    {
        if(Scene_inf.isChecked())
        {
            infinity_scene=1;
        }else {
            infinity_scene=0;
        }
        if(scene_on_off.isChecked())
        {
            Scene_state=1;
        }else {
            Scene_state=0;
        }
        //int z_1,z_2,z_3,z_4;
        //if (Zone1.isChecked()){z_1=1;}else{z_1=0;}
        //if (Zone2.isChecked()){z_2=1;}else{z_2=0;}
        //if (Zone3.isChecked()){z_3=1;}else{z_3=0;}
        //if (Zone4.isChecked()){z_4=1;}else{z_4=0;}
        //Scenes_Zone =Integer.toString((z_4*8)+(z_3*4)+(z_2*2)+z_1, 16);
    }

    public void setting_Scenes(final int number, final String name, int duration, int transtion)
    {
        View view_Amb=inflater_list.inflate(R.layout.ambiance_list, null);

        View_Amb viewHolder = new View_Amb();
        viewHolder.numero = view_Amb.findViewById(R.id.ambiance_number);
        viewHolder.view_display=view_Amb.findViewById(R.id.ambiance_view);
        viewHolder.ambiance_name = view_Amb.findViewById(R.id.ambiance_name);
        viewHolder.durree = view_Amb.findViewById(R.id.duree);
        viewHolder.transition = view_Amb.findViewById(R.id.transitions);
        viewHolder.delete=view_Amb.findViewById(R.id.delete_amb);
        view_Amb.setTag(viewHolder);

        Ambiance_number.add(viewHolder.numero);
        Ambiance_name.add(viewHolder.ambiance_name);
        Ambiance_duree.add(viewHolder.durree);
        Ambiance_transition.add(viewHolder.transition);
        Ambiance_delete.add(viewHolder.delete);

        GradientDrawable shape_ambiance =  new GradientDrawable();

        shape_ambiance.setShape(GradientDrawable.OVAL);
        shape_ambiance.setSize(30,30);
        shape_ambiance.setStroke(5, ContextCompat.getColor(getContext(),R.color.White));

        if(name.equals(couleur_name1))
        {
            shape_ambiance.setColor(white_selection(Blanche1,R1,V1,B1));
        }
        if(name.equals(couleur_name2))
        {
            shape_ambiance.setColor(white_selection(Blanche2,R2,V2,B2));
        }
        if(name.equals(couleur_name3))
        {
            shape_ambiance.setColor(white_selection(Blanche3,R3,V3,B3));
        }
        if(name.equals(couleur_name4))
        {
            shape_ambiance.setColor(white_selection(Blanche4,R4,V4,B4));
        }

        Ambiance_delete.get(number).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                delete_amb(name,number);
            }
        });

        viewHolder.numero.setText(String.valueOf(number));
        viewHolder.view_display.setBackground(shape_ambiance);
        viewHolder.ambiance_name.setText(name);
        viewHolder.durree.setSelection(duration);
        viewHolder.transition.setSelection(transtion);

        Ambiance_duree.get(number).setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if(Saving_scene)
                {
                    Saving_Scene();
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });
        Ambiance_transition.get(number).setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if(Saving_scene)
                {
                    Saving_Scene();
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });

        LayoutList.addView(view_Amb);
    }

    public void Add_ambiance()
    {
        if(Your_Scene.names().length()<MAX_SCENES) {
            final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
            LinearLayout layout = new LinearLayout(getContext());
            layout.setOrientation(LinearLayout.VERTICAL);
            LinearLayout layout2 = new LinearLayout(getContext());
            layout2.setOrientation(LinearLayout.HORIZONTAL);
            final TextView prof_col = new TextView(getContext());
            String col = "Nouvelle Ambiance : ";
            prof_col.setText(col);
            final LinearLayout.LayoutParams lparam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            prof_col.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
            layout2.addView(prof_col);
            final Spinner ambs = new Spinner(getContext());
            ambs.setLayoutParams(lparam);
            ArrayAdapter<String> adapter_profile;
            String[] arraySpinner = new String[4];
            arraySpinner[0] = couleur_name1;
            arraySpinner[1] = couleur_name2;
            arraySpinner[2] = couleur_name3;
            arraySpinner[3] = couleur_name4;
            adapter_profile = new ArrayAdapter<>(getActivity(), R.layout.spinner_item, arraySpinner);
            adapter_profile.setDropDownViewResource(R.layout.drop_list_spinner);
            ambs.setAdapter(adapter_profile);
            layout2.addView(ambs);
            layout.addView(layout2);
            builder.setMessage("Voulez-vous ajouter une nouvelle ambiance ?")
                    .setTitle("Ambiance")
                    .setView(layout)
                    .setCancelable(true)
                    .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                        public void onClick(final DialogInterface dialog, final int id) {
                            try {
                                JSONArray new_Ambi = new JSONArray();
                                new_Ambi.put(ambs.getSelectedItemPosition());
                                new_Ambi.put(0);
                                new_Ambi.put(0);
                                Your_Scene.put(String.valueOf(Your_Scene.names().length()), new_Ambi);
                                saving_zone_state();
                                Scènes.put("scenes", Your_Scene);
                                Scènes.put("inf",infinity_scene);
                                JSONArray state_zone =new JSONArray();
                                state_zone.put(Scene_state);
                                state_zone.put(Scenes_Zone);
                                state_zone.put(SceneOnHeu);
                                state_zone.put(SceneOnMin);
                                state_zone.put(SceneOffHeu);
                                state_zone.put(SceneOffMin);
                                Scènes.put("zone_act",state_zone);
                                save("Scenes.txt", Scènes.toString());
                            } catch (Throwable t) {
                                t.fillInStackTrace();
                            }
                            restart_Scenes = true;
                            dialog.cancel();
                        }
                    })
                    .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                        public void onClick(final DialogInterface dialog, final int id) {
                            dialog.cancel();
                        }
                    });
            final AlertDialog alert = builder.create();
            alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
            alert.show();
        }else
        {
            Toast.makeText(getContext(),"Ce mode a un max de 40 ambiances ", Toast.LENGTH_LONG).show();
        }
    }

    public void delete_amb(String amb_name,int amb_number)
    {
        if(Your_Scene.names().length()>MIN_SCENES) {
            final int amb_del = amb_number;
            final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
            builder.setMessage("Voulez-vous supprimer cette ambiance \"" + amb_name + "\" ?")
                    .setTitle("Attention")
                    .setCancelable(true)
                    .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                        public void onClick(final DialogInterface dialog, final int id) {
                            try {
                                if (!(amb_del == Your_Scene.names().length())) {
                                    for (int g = amb_del; g < Your_Scene.names().length() - 1; g++) {
                                        JSONArray del_array = new JSONArray();
                                        del_array = Your_Scene.getJSONArray(String.valueOf(g + 1));
                                        Your_Scene.remove(String.valueOf(g));
                                        Your_Scene.put(String.valueOf(g), del_array);
                                    }
                                    Your_Scene.remove(String.valueOf(Your_Scene.names().length() - 1));
                                } else {
                                    Your_Scene.remove(String.valueOf(amb_del));
                                }
                                saving_zone_state();
                                Scènes.put("scenes", Your_Scene);
                                Scènes.put("inf",infinity_scene);
                                JSONArray state_zone =new JSONArray();
                                state_zone.put(Scene_state);
                                state_zone.put(Scenes_Zone);
                                state_zone.put(SceneOnHeu);
                                state_zone.put(SceneOnMin);
                                state_zone.put(SceneOffHeu);
                                state_zone.put(SceneOffMin);
                                Scènes.put("zone_act",state_zone);
                                save("Scenes.txt", Scènes.toString());
                            } catch (Throwable t) {
                                Log.e("Scenes", "the scene is = " + Your_Scene.toString());
                                t.printStackTrace();
                            }
                            restart_Scenes = true;
                            dialog.cancel();
                        }
                    })
                    .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                        public void onClick(final DialogInterface dialog, final int id) {
                            dialog.cancel();
                        }
                    });
            final AlertDialog alert = builder.create();
            alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
            alert.show();
        }else
        {
            Toast.makeText(getContext(),"Ce mode a un min d'une ambiance ", Toast.LENGTH_LONG).show();
        }
    }

    public void Saving_Scene()
    {
        //Log.i("My App", "this is scene : "+Scènes.toString());
        try {
            int amb_number=0;
            for(int i=0;i<Ambiance_number.size();i++)
            {
                JSONArray Amb =new JSONArray();
                if (Ambiance_name.get(i).getText().toString().equals(couleur_name1))
                {
                    amb_number=0;
                }
                if (Ambiance_name.get(i).getText().toString().equals(couleur_name2))
                {
                    amb_number=1;
                }
                if (Ambiance_name.get(i).getText().toString().equals(couleur_name3))
                {
                    amb_number=2;
                }
                if (Ambiance_name.get(i).getText().toString().equals(couleur_name4))
                {
                    amb_number=3;
                }
                Amb.put(amb_number);Amb.put(Ambiance_duree.get(i).getSelectedItemPosition());Amb.put(Ambiance_transition.get(i).getSelectedItemPosition());
                Your_Scene.put(Ambiance_number.get(i).getText().toString(),Amb);
            }
            Scènes.put("scenes",Your_Scene);
            saving_zone_state();
            Scènes.put("inf",infinity_scene);
            JSONArray state_zone =new JSONArray();
            state_zone.put(Scene_state);
            state_zone.put(Scenes_Zone);
            state_zone.put(SceneOnHeu);
            state_zone.put(SceneOnMin);
            state_zone.put(SceneOffHeu);
            state_zone.put(SceneOffMin);
            Scènes.put("zone_act",state_zone);
            save("Scenes.txt",Scènes.toString());
            Ble_write_scene();
        }catch (Throwable t)
        {
            save("Scenes.txt",scene_default);
            Log.e("Scenes","the scene is = "+Scènes.toString());
            t.fillInStackTrace();
        }
    }

    public void Ble_write_scene()
    {
        try {
            JSONObject Scene = new JSONObject();
            JSONArray state_zone = new JSONArray();
            state_zone.put(Scene_state);
            state_zone.put(Scenes_Zone);
            state_zone.put(((((SceneOnHeu*100)+SceneOnMin)/100)*3600)+((((SceneOnHeu*100)+SceneOnMin)%100)*60));
            state_zone.put(((((SceneOffHeu*100)+SceneOffMin)/100)*3600)+((((SceneOffHeu*100)+SceneOffMin)%100)*60));
            Scene.put("AZ", state_zone);
            Scene.put("inf", infinity_scene);
            Scene.put("Seq", Your_Scene);
            Log.i("Scenes", "the scene is = " + Scene.toString());
            if (mConnected) {
                Boolean check = false;
                do {
                    check = writecharacteristic(3, 0, Scene.toString());
                    if (check) {
                        Toast.makeText(getContext(), "Scène enregistrée !", Toast.LENGTH_SHORT).show();
                    }
                    if (!mConnected) {
                        break;
                    }
                }
                while (!check);
            }
        }catch (Throwable t)
        {
            t.fillInStackTrace();
        }
    }

    /*public void read_zones(){
        Zone1.setTextOff(Zone_1);
        Zone1.setTextOn(Zone_1);
        Zone1.setText(Zone_1);
        Zone2.setTextOff(Zone_2);
        Zone2.setTextOn(Zone_2);
        Zone2.setText(Zone_2);
        Zone3.setTextOff(Zone_3);
        Zone3.setTextOn(Zone_3);
        Zone3.setText(Zone_3);
        Zone4.setTextOff(Zone_4);
        Zone4.setTextOn(Zone_4);
        Zone4.setText(Zone_4);
    }*/

    public boolean fileExists(Context context, String filename)
    {
        File file = context.getFileStreamPath(filename);
        if(file == null || !file.exists())
        {
            return false;
        }
        else {
            return true;
        }
    }

    public void save(String FILE_NAME,String text) {
        FileOutputStream fos = null;
        try {
            fos = getActivity().openFileOutput(FILE_NAME, MODE_PRIVATE);
            fos.write(text.getBytes());
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (fos != null) {
                try {
                    fos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public String load(String FILE_NAME) {
        FileInputStream fis = null;

        try {
            fis = getActivity().openFileInput(FILE_NAME);
            InputStreamReader isr = new InputStreamReader(fis);
            BufferedReader br = new BufferedReader(isr);
            StringBuilder sb = new StringBuilder();
            String text;

            while ((text = br.readLine()) != null) {
                sb.append(text).append("\n");
            }
            return sb.toString();

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (fis != null) {
                try {
                    fis.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return null;
    }
    public void read_text_json(){
        if (!fileExists(getActivity().getApplicationContext(),"Favoris.txt"))
        {
            save("Favoris.txt",Favoris);
        }
        String les_favoris=load("Favoris.txt");
        try {
            JSONObject colors =new JSONObject(les_favoris);
            JSONArray color1 = colors.getJSONArray("couleur1");
            couleur_name1 = color1.getString(0);
            stabilisation1 = color1.getInt(1);
            R1 = color1.getInt(2);
            V1 = color1.getInt(3);
            B1 = color1.getInt(4);
            Zo1 =color1.getString(5);
            L1 =color1.getInt(6);
            Blanche1 =color1.getInt(7);
            JSONArray color2 = colors.getJSONArray("couleur2");
            couleur_name2 = color2.getString(0);
            stabilisation2 = color2.getInt(1);
            R2 = color2.getInt(2);
            V2 = color2.getInt(3);
            B2 = color2.getInt(4);
            Zo2 =color2.getString(5);
            L2 =color2.getInt(6);
            Blanche2 =color2.getInt(7);
            JSONArray color3 = colors.getJSONArray("couleur3");
            couleur_name3 = color3.getString(0);
            stabilisation3 = color3.getInt(1);
            R3 = color3.getInt(2);
            V3 = color3.getInt(3);
            B3 = color3.getInt(4);
            Zo3 =color3.getString(5);
            L3 =color3.getInt(6);
            Blanche3 =color3.getInt(7);
            JSONArray color4 = colors.getJSONArray("couleur4");
            couleur_name4 = color4.getString(0);
            stabilisation4 = color4.getInt(1);
            R4 = color4.getInt(2);
            V4 = color4.getInt(3);
            B4 = color4.getInt(4);
            Zo4 =color4.getString(5);
            L4 =color4.getInt(6);
            Blanche4 =color4.getInt(7);
        }catch (Throwable t) {
            Log.e("My App", "Could not parse malformed JSON: " + les_favoris);
            save("Favoris.txt",Favoris);
            couleur_name1="Ambiance1";couleur_name2="Ambiance2";couleur_name3="Ambiance3";couleur_name4="Ambiance4";
            stabilisation1=0;stabilisation2=0;stabilisation3=0;stabilisation4=0;
            R1=0;R2=0;R3=0;R4=0;
            V1=0;V2=0;V3=0;V4=0;
            B1=0;B2=0;B3=0;B4=0;
            Blanche1=0;Blanche2=0;Blanche3=0;Blanche4=0;
            Zo1="0";Zo2="0";Zo3="0";Zo4="0";
            L1=0;L2=0;L3=0;L4=0;
        }
    }
    private BluetoothGattCharacteristic mNotifyCharacteristic;
    public boolean writecharacteristic(int i,int j, String data){
        boolean write=false;
        bleReadWrite=true;
        try {
            final BluetoothGattCharacteristic charac = mGattCharacteristics.get(i).get(j);
            final int charaProp = charac.getProperties();
            byte[] values = data.getBytes();
            charac.setValue(values);
            charac.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
            if ((charaProp | BluetoothGattCharacteristic.PROPERTY_WRITE) > 0) {
                if (mNotifyCharacteristic != null) {
                    mBluetoothLeService.setCharacteristicNotification(mNotifyCharacteristic, false);
                    mNotifyCharacteristic = null;
                }
                write = mBluetoothLeService.writeCharacteristic(charac);
                bleReadWrite = false;
            }
            if ((charaProp | BluetoothGattCharacteristic.PROPERTY_NOTIFY) > 0) {
                mNotifyCharacteristic = charac;
                mBluetoothLeService.setCharacteristicNotification(charac, true);
            }
        }catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        return write;
    }
}