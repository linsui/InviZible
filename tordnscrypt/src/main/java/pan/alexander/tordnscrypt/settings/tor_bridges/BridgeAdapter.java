package pan.alexander.tordnscrypt.settings.tor_bridges;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.SwitchCompat;
import androidx.cardview.widget.CardView;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Objects;

import pan.alexander.tordnscrypt.R;
import pan.alexander.tordnscrypt.SettingsActivity;
import pan.alexander.tordnscrypt.dialogs.NotificationDialogFragment;
import pan.alexander.tordnscrypt.utils.enums.BridgeType;
import pan.alexander.tordnscrypt.utils.file_operations.FileOperations;

class BridgeAdapter extends RecyclerView.Adapter<BridgeAdapter.BridgeViewHolder> {
    private SettingsActivity activity;
    private FragmentManager fragmentManager;
    private LayoutInflater lInflater;
    private PreferencesBridges preferencesBridges;

    BridgeAdapter(SettingsActivity activity, FragmentManager fragmentManager, PreferencesBridges preferencesBridges) {
        this.activity = activity;
        this.fragmentManager = fragmentManager;
        this.preferencesBridges = preferencesBridges;
        this.lInflater = (LayoutInflater) Objects.requireNonNull(activity).getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    @NonNull
    @Override
    public BridgeAdapter.BridgeViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = lInflater.inflate(R.layout.item_bridge, parent, false);
        return new BridgeViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull BridgeAdapter.BridgeViewHolder holder, int position) {
        holder.bind(position);
    }

    @Override
    public int getItemCount() {
        return preferencesBridges.getBridgeList().size();
    }

    private ObfsBridge getItem(int position) {
        return preferencesBridges.getBridgeList().get(position);
    }

    private void setActive(int position, boolean active) {
        List<ObfsBridge> bridgeList = preferencesBridges.getBridgeList();
        ObfsBridge brg = bridgeList.get(position);
        brg.active = active;
        bridgeList.set(position, brg);
    }

   class BridgeViewHolder extends RecyclerView.ViewHolder {

        private TextView tvBridge;
        private SwitchCompat swBridge;

        BridgeViewHolder(@NonNull View itemView) {
            super(itemView);

            tvBridge = itemView.findViewById(R.id.tvBridge);
            swBridge = itemView.findViewById(R.id.swBridge);
            CompoundButton.OnCheckedChangeListener onCheckedChangeListener = (compoundButton, newValue) -> {
                List<String> currentBridges = preferencesBridges.getCurrentBridges();

                if (newValue) {
                    BridgeType obfsType = getItem(getAdapterPosition()).obfsType;
                    if (!obfsType.equals(preferencesBridges.getCurrentBridgesType())) {
                        currentBridges.clear();
                        setCurrentBridgesType(obfsType);
                    }

                    boolean unicBridge = true;
                    for (int i = 0; i < currentBridges.size(); i++) {
                        String brg = currentBridges.get(i);
                        if (brg.equals(getItem(getAdapterPosition()).bridge)) {
                            unicBridge = false;
                            break;
                        }
                    }
                    if (unicBridge)
                        currentBridges.add(getItem(getAdapterPosition()).bridge);
                } else {
                    for (int i = 0; i < currentBridges.size(); i++) {
                        String brg = currentBridges.get(i);
                        if (brg.equals(getItem(getAdapterPosition()).bridge)) {
                            currentBridges.remove(i);
                            break;
                        }

                    }
                }
                setActive(getAdapterPosition(), newValue);
            };
            swBridge.setOnCheckedChangeListener(onCheckedChangeListener);
            ImageButton ibtnBridgeDel = itemView.findViewById(R.id.ibtnBridgeDel);
            View.OnClickListener onClickListener = view -> {
                switch (view.getId()) {
                    case R.id.cardBridge:
                        editBridge(getAdapterPosition());
                        break;
                    case R.id.ibtnBridgeDel:
                        deleteBridge(getAdapterPosition());
                        break;
                }
            };
            ibtnBridgeDel.setOnClickListener(onClickListener);
            CardView cardBridge = itemView.findViewById(R.id.cardBridge);
            cardBridge.setOnClickListener(onClickListener);
        }

        private void bind(int position) {
            List<ObfsBridge> bridgeList = preferencesBridges.getBridgeList();

            if (bridgeList == null || bridgeList.isEmpty() || position >= bridgeList.size()) {
                return;
            }

            String[] bridgeIP = bridgeList.get(position).bridge.split(" ");

            if (bridgeIP.length == 0) {
                return;
            }

            String tvBridgeText;
            if ((bridgeIP[0].contains("obfs3") || bridgeIP[0].contains("obfs4")
                    || bridgeIP[0].contains("scramblesuit") || bridgeIP[0].contains("meek_lite"))
                    && bridgeIP.length > 1) {
                tvBridgeText = bridgeIP[0] + " " + bridgeIP[1];
            } else {
                tvBridgeText = bridgeIP[0];
            }

            tvBridge.setText(tvBridgeText);
            if (bridgeList.get(position).active) {
                swBridge.setChecked(true);
            } else {
                swBridge.setChecked(false);
            }
        }

    }

    private void editBridge(final int position) {

        if (activity == null) {
            return;
        }

        AlertDialog.Builder builder = new AlertDialog.Builder(activity, R.style.CustomAlertDialogTheme);
        builder.setTitle(R.string.pref_fast_use_tor_bridges_edit);

        List<ObfsBridge> bridgeList = preferencesBridges.getBridgeList();
        String bridges_file_path = preferencesBridges.get_bridges_file_path();

        LayoutInflater inflater = activity.getLayoutInflater();
        @SuppressLint("InflateParams") final View inputView = inflater.inflate(R.layout.edit_text_for_dialog, null, false);
        final EditText input = inputView.findViewById(R.id.etForDialog);
        input.setSingleLine(false);
        String brgEdit = bridgeList.get(position).bridge;
        BridgeType obfsTypeEdit = bridgeList.get(position).obfsType;
        final boolean activeEdit = bridgeList.get(position).active;
        if (activeEdit && fragmentManager != null) {
            DialogFragment commandResult
                    = NotificationDialogFragment.newInstance(activity.getString(R.string.pref_fast_use_tor_bridges_deactivate));
            commandResult.show(fragmentManager, "NotificationDialogFragment");
            return;
        }
        input.setText(brgEdit, TextView.BufferType.EDITABLE);
        builder.setView(inputView);

        builder.setPositiveButton(activity.getText(R.string.ok), (dialog, i) -> {
            String inputText = input.getText().toString();

            ObfsBridge brg = new ObfsBridge(inputText, obfsTypeEdit, false);
            bridgeList.set(position, brg);
            preferencesBridges.getBridgeAdapter().notifyItemChanged(position);

            List<String> tmpList = new LinkedList<>();
            for (ObfsBridge tmpObfs : bridgeList) {
                tmpList.add(tmpObfs.bridge);
            }
            tmpList.addAll(preferencesBridges.getAnotherBridges());
            Collections.sort(tmpList);
            if (bridges_file_path != null)
                FileOperations.writeToTextFile(activity, bridges_file_path, tmpList, "ignored");
        });
        builder.setNegativeButton(activity.getText(R.string.cancel), (dialog, i) -> dialog.cancel());
        builder.show();
    }

    private void deleteBridge(int position) {
        List<ObfsBridge> bridgeList = preferencesBridges.getBridgeList();
        String bridges_file_path = preferencesBridges.get_bridges_file_path();

        if (bridgeList.get(position).active && fragmentManager != null) {
            DialogFragment commandResult
                    = NotificationDialogFragment.newInstance(activity.getString(R.string.pref_fast_use_tor_bridges_deactivate));
            commandResult.show(fragmentManager, "NotificationDialogFragment");
            return;
        }
        bridgeList.remove(position);
        preferencesBridges.getBridgeAdapter().notifyItemRemoved(position);

        List<String> tmpList = new LinkedList<>();
        for (ObfsBridge tmpObfs : bridgeList) {
            tmpList.add(tmpObfs.bridge);
        }
        tmpList.addAll(preferencesBridges.getAnotherBridges());
        Collections.sort(tmpList);
        if (bridges_file_path != null)
            FileOperations.writeToTextFile(activity, bridges_file_path, tmpList, "ignored");
    }

    private void setCurrentBridgesType(BridgeType type) {
        preferencesBridges.setCurrentBridgesType(type);
    }
}
