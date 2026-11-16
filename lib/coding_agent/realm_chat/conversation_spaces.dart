/// The conversation spaces layer, imported from the harness package
/// (harness ADR 0144): channels, work-thread links and the thread-kind
/// classifier moved verbatim from LA (LA ADR 0024 / 0129) into
/// `pkgs/ecsly_conversation` — a code move, not a data migration (the
/// `channels` / `work_threads` collections and their record shapes are
/// byte-identical). This file is LA's narrow seam: UI files import the
/// spaces vocabulary without pulling the whole ontology barrel in.
library;

export 'package:ecsly_conversation/ecsly_conversation.dart'
    show
        ChannelInfo,
        ChannelNameCheck,
        ChannelNaming,
        ChannelRegistry,
        ConversationKind,
        WorkThreadLink,
        WorkThreadRegistry,
        classifyThread;
