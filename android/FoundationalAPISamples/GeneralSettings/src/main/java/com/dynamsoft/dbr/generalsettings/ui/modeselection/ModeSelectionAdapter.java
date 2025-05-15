package com.dynamsoft.dbr.generalsettings.ui.modeselection;

import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.dbr.generalsettings.R;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class ModeSelectionAdapter extends RecyclerView.Adapter<ModeSelectionAdapter.ViewHolder> implements ItemTouchHelperInter {

    private List<Pair<Integer, String>> modesList;
    private int[] modesArray;
    private int maxItemCount;
    private ModesArrayChangedListener listener;
    private int itemCount = 0;
    private int lastItemCount = 0;

    public ModeSelectionAdapter(List<Pair<Integer, String>> modesList, int[] modesArray, int maxItemCount, ModesArrayChangedListener listener) {
        this.modesList = modesList;
        this.modesArray = modesArray;
        this.maxItemCount = maxItemCount;
        this.listener = listener;
        setItemCount();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.modes_selection_spinner_item, parent, false);
        ViewHolder viewHolder = new ViewHolder(view);
        ArrayList<String> modeStringList = new ArrayList<>();
        for (Pair<Integer, String> pair : modesList) {
            modeStringList.add(pair.second);
        }
        viewHolder.spModes.setAdapter(new ArrayAdapter<>(parent.getContext(), R.layout.modes_selection_spinner_text, modeStringList.toArray(new String[0])));
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Spinner spinner = holder.spModes;
        ArrayList<Integer> modesSortedByPosition = new ArrayList<>();
        for (Pair<Integer, String> pair : modesList) {
            modesSortedByPosition.add(pair.first);
        }
        int positionOfThisMode = modesArray.length <= holder.getAdapterPosition() ? modesSortedByPosition.size() - 1
                : modesSortedByPosition.lastIndexOf(modesArray[holder.getAdapterPosition()]);
        spinner.setSelection(positionOfThisMode);

        lastItemCount = itemCount;
        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int spPosition, long id) {
                int value = modesSortedByPosition.get(spPosition);
                notifyItemChanged(holder.getAdapterPosition());
                if (value <= 0) {
                    for (int i = holder.getAdapterPosition() + 1; i < modesArray.length; i++) {
                        modesArray[i] = -1;
                        listener.onModesArrayChanged(modesArray);
                    }
                } else {
                    for (int i = 0; i < modesArray.length; i++) {
                        if (i != holder.getAdapterPosition() && modesArray[i] == value) {
                            showModeDialog(spinner, positionOfThisMode);
                            return;
                        }
                    }
                }
                //Update data in the same time
                modesArray[holder.getAdapterPosition()] = value;
                listener.onModesArrayChanged(modesArray);

                for (int i = 0; i < modesArray.length; i++) {
                    if (modesArray[i] <= 0) {
                        itemCount = Math.min(i + 1, maxItemCount);
                        break;
                    }
                }

                if (itemCount < lastItemCount) {
                    notifyItemRangeRemoved(itemCount, lastItemCount);
                    lastItemCount = itemCount;
                } else if (itemCount > lastItemCount) {
                    notifyItemInserted(lastItemCount);
                    lastItemCount = itemCount;
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });
    }

    public void setItemCount() {
        int count = 0;
        for (int i = 0; i < modesArray.length; i++) {
            if (modesArray[i] <= 0) {
                count = i;
                break;
            } else if (i == modesArray.length - 1) {
                count = maxItemCount;
            }
        }
        itemCount = Math.min(count, maxItemCount);
    }

    @Override
    public int getItemCount() {
        return itemCount;
    }

    private void showModeDialog(Spinner spinner, int index) {
        new AlertDialog.Builder(spinner.getContext())
                .setMessage("Please don't select the same mode.")
                .setOnDismissListener(dialog -> spinner.setSelection(index))
                .show();
    }

    @Override
    public void onItemChange(int fromPos, int toPos) {
        int temp = modesArray[fromPos];
        modesArray[fromPos] = modesArray[toPos];
        modesArray[toPos] = temp;
        notifyItemMoved(fromPos, toPos);
    }

    @Override
    public void onItemDelete(int pos) {

    }

    @Override
    public void onActionIdle() {
        int indexOfFirstZero = -1;
        for (int i = 0; i < modesArray.length; i++) {
            if(modesArray[i] <= 0) {
                indexOfFirstZero = i;
                break;
            }
        }
        if (indexOfFirstZero != -1 && indexOfFirstZero < itemCount - 1) {
            Arrays.fill(modesArray, indexOfFirstZero, modesArray.length, 0);
            notifyItemRangeRemoved(indexOfFirstZero + 1, itemCount - indexOfFirstZero);
            notifyItemChanged(indexOfFirstZero);
            itemCount = indexOfFirstZero + 1;
        }
        listener.onModesArrayChanged(modesArray);
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        Spinner spModes;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            spModes = itemView.findViewById(R.id.sp_item);
        }
    }

    public interface ModesArrayChangedListener {
        void onModesArrayChanged(int[] modesArray);
    }
}
