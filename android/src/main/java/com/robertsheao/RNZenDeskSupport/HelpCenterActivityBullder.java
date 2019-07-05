package com.robertsheao.RNZenDeskSupport;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.zendesk.logger.Logger;
import zendesk.support.guide.HelpCenterActivity;
import com.zendesk.util.CollectionUtils;

import java.util.ArrayList;

/**
 * Created by Patrick O'Connor on 11/8/17.
 * This is a mostly a copy of Zendesk's HelpCenterActivity.Builder.class, modified slightly to allow configuration from the React Native module.
 * It also adds the Intent.FLAG_ACTIVITY_NEW_TASK flag to the created Intent, fixing a crashing bug in older versions of Android.
 * https://github.com/RobertSheaO/react-native-zendesk-support
 */

class HelpCenterActivityBuilder {
  private final Bundle args = new Bundle();

  private HelpCenterActivityBuilder() {
  }

  private static long[] toLongArray(ArrayList<?> values) {
    long[] arr = new long[values.size()];
    for (int i = 0; i < values.size(); i++)
      arr[i] = Long.parseLong((String) values.get(i));
    return arr;
  }

  static HelpCenterActivityBuilder create() {

    HelpCenterActivityBuilder builder = new HelpCenterActivityBuilder();
    builder.withContactUsButtonVisible(true);

    return builder;
  }

  HelpCenterActivityBuilder withOptions(ReadableMap options) {
    if (!(options == null || options.toHashMap().isEmpty())) {
      if (options.hasKey("withContactUsButtonVisible")) {
        switch(options.getString("withContactUsButtonVisible")) {
          case "OFF":
            withContactUsButtonVisible(false);
            break;
          case "ARTICLE_LIST_ONLY":
          case "ARTICLE_LIST_AND_ARTICLE":
          default:
            withContactUsButtonVisible(true);
        }
      }
    }
    return this;
  }

  HelpCenterActivityBuilder withArticlesForCategoryIds(ReadableArray categoryIds) {
    return withArticlesForCategoryIds(toLongArray(categoryIds.toArrayList()));
  }

  private HelpCenterActivityBuilder withArticlesForCategoryIds(long... categoryIds) {
    if(this.args.getLongArray("extra_section_ids") != null) {
      Logger.w("HelpCenterActivity", "Builder: sections have already been specified. Removing section IDs to set category IDs.", new Object[0]);
      this.args.remove("extra_section_ids");
    }

    this.args.putLongArray("extra_category_ids", categoryIds);
    return this;
  }

  HelpCenterActivityBuilder withArticlesForSectionIds(ReadableArray sectionIds) {
    return withArticlesForSectionIds(toLongArray(sectionIds.toArrayList()));
  }

  private HelpCenterActivityBuilder withArticlesForSectionIds(long... sectionIds) {
    if(this.args.getLongArray("extra_category_ids") != null) {
      Logger.w("HelpCenterActivity", "Builder: categories have already been specified. Removing category IDs to set section IDs.", new Object[0]);
      this.args.remove("extra_category_ids");
    }

    this.args.putLongArray("extra_section_ids", sectionIds);
    return this;
  }

  /** @deprecated */
  HelpCenterActivityBuilder showContactUsButton(boolean showContactUsButton) {
    this.args.putBoolean("extra_contact_us_button_visibility", showContactUsButton? true: false);
    return this;
  }

  private HelpCenterActivityBuilder withContactUsButtonVisible(boolean contactUsButtonVisibility) {
    this.args.putBoolean("extra_contact_us_button_visibility", contactUsButtonVisibility);
    return this;
  }

  //noinspection SuspiciousToArrayCall
  HelpCenterActivityBuilder withLabelNames(ReadableArray labelNames) {
    return withLabelNames(labelNames.toArrayList().toArray(new String[]{}));
  }

  private HelpCenterActivityBuilder withLabelNames(String... labelNames) {
    if(CollectionUtils.isNotEmpty(labelNames)) {
      this.args.putStringArray("extra_label_names", labelNames);
    }

    return this;
  }

  private HelpCenterActivityBuilder withCategoriesCollapsed(boolean categoriesCollapsed) {
    this.args.putBoolean("extra_categories_collapsed", categoriesCollapsed);
    return this;
  }

  private HelpCenterActivityBuilder showConversationsMenuButton(boolean showConversationsMenuButton) {
    this.args.putBoolean("extra_show_conversations_menu_button", showConversationsMenuButton);
    return this;
  }

  private HelpCenterActivityBuilder withArticleVoting(boolean articleVotingEnabled) {
    this.args.putBoolean("article_voting_enabled", articleVotingEnabled);
    return this;
  }

  void show(Context context) {
    HelpCenterActivity.builder()
            .show(context);
  }

  private Intent intent(Context context) {
    Logger.d("HelpCenterActivity", "intent: creating Intent", new Object[0]);
    Intent intent = new Intent(context, HelpCenterActivity.class);
    intent.putExtras(this.args);
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    return intent;
  }
}
