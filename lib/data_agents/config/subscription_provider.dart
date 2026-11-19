/// Subscription plans as a provider type (ADR 0031).
///
/// ChatGPT and Grok stay device sign-in stores. An actor names the
/// provider and the model. This file turns that name into a client
/// factory and into the picker rows. It does not write the account's
/// selected model, and it does not put `subscription` into the harness
/// palette (that transport is refused).
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:lastanswer/data_agents/subscriptions/chatgpt_harness_binding.dart';
import 'package:lastanswer/data_agents/subscriptions/chatgpt_subscription_controller.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_harness_binding.dart';
import 'package:lastanswer/data_agents/subscriptions/grok_subscription_controller.dart';
import 'package:lastanswer/journal/palette_lanes.dart';
import 'package:provider/provider.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

/// One model a signed-in subscription provider can offer an actor.
typedef SubscriptionModelChoice = ({
  String providerId,
  String model,
  String label,
});

/// Models the signed-in plans can run right now. A plan that is signed
/// out or missing `planEnabled` contributes nothing. The account's
/// selected model is included when the catalog has not listed it yet,
/// so the actor can still name the model the account already holds.
List<SubscriptionModelChoice> subscriptionBrainChoices({
  final ChatGptSubscriptionController? chatgpt,
  final GrokSubscriptionController? grok,
}) {
  final out = <SubscriptionModelChoice>[];
  void add(
    final String providerId,
    final String model,
    final String spoken,
    final String lane,
  ) {
    final slug = model.trim();
    if (slug.isEmpty) return;
    if (out.any(
      (final entry) => entry.providerId == providerId && entry.model == slug,
    )) {
      return;
    }
    final name = spoken.trim().isEmpty ? slug : spoken.trim();
    out.add((providerId: providerId, model: slug, label: '$name · $lane'));
  }

  final chatProfile = chatgpt?.activeProfile;
  if (chatgpt != null &&
      chatProfile != null &&
      chatProfile.signedIn &&
      chatProfile.planEnabled) {
    for (final model in chatgpt.models) {
      add(chatGptBackend, model.slug, model.displayName, 'ChatGPT');
    }
    final selected = chatgpt.selectedModel;
    if (selected != null) {
      add(
        chatGptBackend,
        selected,
        brainModelLabel(id: chatGptBackend, model: selected),
        'ChatGPT',
      );
    }
  }
  final grokProfile = grok?.activeProfile;
  if (grok != null &&
      grokProfile != null &&
      grokProfile.signedIn &&
      grokProfile.planEnabled) {
    for (final model in grok.models) {
      add(grokBackend, model.slug, model.displayName, 'Grok');
    }
    final selected = grok.selectedModel;
    if (selected != null) {
      add(
        grokBackend,
        selected,
        brainModelLabel(id: grokBackend, model: selected),
        'Grok',
      );
    }
  }
  return out;
}

/// The picker source. A controller that has not loaded yet starts its
/// load, the same way the account panes do, so the rows appear when
/// the account is readable.
List<SubscriptionModelChoice> subscriptionModelsOf(final BuildContext context) {
  final chatgpt = context.read<ChatGptSubscriptionController?>();
  final grok = context.read<GrokSubscriptionController?>();
  if (chatgpt != null && !chatgpt.initialized && !chatgpt.busy) {
    unawaited(chatgpt.load());
  }
  if (grok != null && !grok.initialized && !grok.busy) {
    unawaited(grok.load());
  }
  return subscriptionBrainChoices(chatgpt: chatgpt, grok: grok);
}

/// A client factory for [providerId] and [model], or null when this
/// device cannot run that pair. The factory closes over the account
/// id and the actor's model. It does not call `selectModel`.
InferenceClient Function()? subscriptionClientFor({
  required final String providerId,
  required final String model,
  final ChatGptSubscriptionController? chatgpt,
  final GrokSubscriptionController? grok,
}) {
  if (model.trim().isEmpty) return null;
  if (providerId == chatGptBackend) {
    final profile = chatgpt?.activeProfile;
    final gateway = chatgpt?.gateway;
    if (profile == null ||
        gateway == null ||
        !profile.signedIn ||
        !profile.planEnabled) {
      return null;
    }
    final account = profile.clientId;
    final slug = model.trim();
    return () => gateway.inferenceClient(account, slug);
  }
  if (providerId == grokBackend) {
    final profile = grok?.activeProfile;
    final gateway = grok?.gateway;
    if (profile == null ||
        gateway == null ||
        !profile.signedIn ||
        !profile.planEnabled) {
      return null;
    }
    final subject = profile.subject;
    final slug = model.trim();
    return () => gateway.inferenceClient(subject, slug);
  }
  return null;
}
