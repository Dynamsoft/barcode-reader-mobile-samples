package com.dynamsoft.dbr.decodefromanimage.ui;

import android.content.Context;
import android.content.res.TypedArray;
import android.net.Uri;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.dynamsoft.dbr.decodefromanimage.R;
import com.dynamsoft.dbr.decodefromanimage.utils.UriUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * ThumbnailsRecyclerView is a custom RecyclerView implementation that displays a list of image thumbnails.
 * It initializes with images from a specified assets directory and supports dynamic addition and selection of images.
 */
public class ThumbnailsRecyclerView extends RecyclerView {

    private final static String INIT_ASSETS_IMAGES_DIR = "image";  // Default assets directory for images.
    private OnItemSelectedListener onItemSelectedListener; // Listener for thumbnail selection events.
    private final ThumbnailAdapter thumbnailAdapter; // Adapter for managing and displaying thumbnails.

    public ThumbnailsRecyclerView(Context context) {
        this(context, null);
    }

    public ThumbnailsRecyclerView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ThumbnailsRecyclerView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        // Determine the orientation from XML attributes or default to HORIZONTAL.
        int orientation = HORIZONTAL;
        if (attrs != null) {
            TypedArray ta = context.obtainStyledAttributes(attrs, new int[]{android.R.attr.orientation});
            orientation = ta.getInt(0, HORIZONTAL);
            ta.recycle();
        }

        setLayoutManager(new LinearLayoutManager(context, orientation, false));
        setItemAnimator(null);

        // Initialize the adapter with image URIs from the assets directory.
        List<Uri> initUrls = UriUtils.getImageUrisFromAssetsDir(context, INIT_ASSETS_IMAGES_DIR);
        thumbnailAdapter = new ThumbnailAdapter(initUrls, uri -> {
            if (onItemSelectedListener != null) {
                onItemSelectedListener.onItemSelected(uri);
            }
        });
        setAdapter(thumbnailAdapter);
    }

    /**
     * Sets the listener for thumbnail selection.
     * When a thumbnail is clicked, the listener callback will be
     * triggered with the corresponding URI.
     *
     * @param listener Listener to handle selection events.
     */
    public void setOnItemSelectedListener(OnItemSelectedListener listener) {
        this.onItemSelectedListener = listener;
    }

    /**
     * Adds a URI to the list, selects it, and scrolls to its position.
     *
     * @param uri The URI of the image to add.
     * @return The position of the added URI.
     */
    public int addUriAndSelect(Uri uri) {
        int position = thumbnailAdapter.addUriAndSelect(uri);
        scrollToPosition(position);
        return position;
    }

    /**
     * Retrieves the currently selected URI.
     *
     * @return The URI of the selected image, or null if no selection exists.
     */
    public Uri getSelectedUri() {
        return thumbnailAdapter.getSelectedUri();
    }

    /**
     * Selects a thumbnail by its position.
     *
     * @param position The position of the thumbnail to select.
     */
    public void selectItem(int position) {
        thumbnailAdapter.selectItem(position);
    }

    /**
     * Listener interface for handling thumbnail selection events.
     */
    public interface OnItemSelectedListener {
        void onItemSelected(@NonNull Uri uri);
    }

    /**
     * ThumbnailAdapter manages the display and selection of thumbnails.
     */
    private static class ThumbnailAdapter extends Adapter<ThumbnailAdapter.ViewHolder> {
        private int selectedPosition = RecyclerView.NO_POSITION;
        private final List<Uri> uriList;
        private final OnItemSelectedListener onItemSelectedListener;

        /**
         * Constructor for ThumbnailAdapter.
         *
         * @param uriList                Initial list of URIs to display.
         * @param onItemSelectedListener Listener for selection events.
         */
        public ThumbnailAdapter(List<Uri> uriList, OnItemSelectedListener onItemSelectedListener) {
            this.uriList = new ArrayList<>(uriList);
            this.onItemSelectedListener = onItemSelectedListener;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_thumbnail, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            Uri uri = uriList.get(position);

            // Load the image using Glide with a fixed small size.
            Glide.with(holder.imageView.getContext())
                    .load(uri)
                    .override(200, 200)
                    .into(holder.imageView);

            // Highlight the selected thumbnail.
            holder.boundary.setVisibility(position == selectedPosition ? View.VISIBLE : View.GONE);
        }

        @Override
        public int getItemCount() {
            return uriList.size();
        }

        /**
         * Adds a URI to the list, selects it, and notifies the adapter.
         *
         * @param uri The URI to add.
         * @return The position of the added or selected URI.
         */
        public int addUriAndSelect(Uri uri) {
            if (!uriList.contains(uri)) {
                uriList.add(uri);
                notifyItemInserted(uriList.size() - 1);
                selectItem(uriList.size() - 1);
                return uriList.size() - 1;
            } else {
                selectItem(uriList.indexOf(uri));
                return uriList.indexOf(uri);
            }
        }

        /**
         * Retrieves the currently selected URI.
         *
         * @return The URI of the selected thumbnail, or the first URI if none is selected.
         */
        public Uri getSelectedUri() {
            if (selectedPosition >= 0 && selectedPosition < uriList.size()) {
                return uriList.get(selectedPosition);
            } else if (!uriList.isEmpty()) {
                return uriList.get(0);
            } else {
                return null;
            }
        }

        /**
         * Selects an item and notifies the adapter of changes.
         *
         * @param position The position of the item to select.
         */
        public void selectItem(int position) {
            if (position >= 0 && position < uriList.size()) {
                int previousPosition = selectedPosition;
                selectedPosition = position;
                notifyItemChanged(previousPosition);
                notifyItemChanged(selectedPosition);
                onItemSelectedListener.onItemSelected(uriList.get(position));
            }
        }

        class ViewHolder extends RecyclerView.ViewHolder {
            ImageView imageView; // ImageView for displaying the thumbnail.
            View boundary; // View for highlighting the selected thumbnail.

            public ViewHolder(@NonNull View itemView) {
                super(itemView);
                imageView = itemView.findViewById(R.id.imageView);
                boundary = itemView.findViewById(R.id.boundary);
                itemView.setOnClickListener(v -> selectItem(getAdapterPosition()));
            }
        }
    }
}