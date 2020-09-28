package deliled.Applications.android.Maestro;

import android.view.View;


import com.eftimoff.viewpagertransformers.BaseTransformer;

public class StackTransformer extends BaseTransformer {

        @Override
        protected void onTransform(View view, float position) {
            view.setTranslationX(position < 0 ? 0f : -view.getWidth() * position);
        }

}
