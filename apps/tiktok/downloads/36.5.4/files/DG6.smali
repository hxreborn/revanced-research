.class public final LX/DG6;
.super Ljava/lang/Object;
.source "SourceFile"


# static fields
.field public static LIZ:Ljava/lang/String;

.field public static volatile isNeedGuard:Z


# direct methods
.method public static constructor <clinit>()V
    .locals 0

    return-void
.end method

.method public static LIZ(Ljava/lang/String;)Z
    .locals 1

    .prologue
    .line 16777216
    if-eqz p0, :cond_0

    .line 16777217
    .line 16777218
    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 16777219
    .line 16777220
    .line 16777221
    move-result v0

    .line 16777222
    if-nez v0, :cond_0

    .line 16777223
    .line 16777224
    new-instance v0, Ljava/io/File;

    .line 16777225
    .line 16777226
    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 16777227
    .line 16777228
    .line 16777229
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    .line 16777230
    .line 16777231
    .line 16777232
    move-result v0

    .line 16777233
    return v0

    .line 16777234
    :cond_0
    const/4 v0, 0x0

    .line 16777235
    return v0
.end method

.method public static LIZIZ(Ljava/lang/String;Ljava/lang/String;)V
    .locals 10

    .prologue
    .line 33554432
    const-string v0, "srcPath"

    .line 33554433
    .line 33554434
    invoke-static {p0, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 33554435
    .line 33554436
    .line 33554437
    const-string v0, "destPath"

    .line 33554438
    .line 33554439
    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 33554440
    .line 33554441
    .line 33554442
    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 33554443
    .line 33554444
    .line 33554445
    move-result v0

    .line 33554446
    if-nez v0, :cond_b

    .line 33554447
    .line 33554448
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 33554449
    .line 33554450
    .line 33554451
    move-result v0

    .line 33554452
    if-nez v0, :cond_b

    .line 33554453
    .line 33554454
    new-instance v0, Ljava/io/File;

    .line 33554455
    .line 33554456
    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554457
    .line 33554458
    .line 33554459
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    .line 33554460
    .line 33554461
    .line 33554462
    move-result v0

    .line 33554463
    if-nez v0, :cond_0

    .line 33554464
    .line 33554465
    return-void

    .line 33554466
    :cond_0
    const/4 v0, 0x1

    .line 33554467
    invoke-static {p1, v0}, LX/DG6;->LIZJ(Ljava/lang/String;Z)V

    .line 33554468
    .line 33554469
    .line 33554470
    :try_start_0
    const-string v1, "mounted"

    .line 33554471
    .line 33554472
    invoke-static {}, LX/ccj;->H()Ljava/lang/String;

    .line 33554473
    .line 33554474
    .line 33554475
    move-result-object v0

    .line 33554476
    invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->LJ(Ljava/lang/Object;Ljava/lang/Object;)Z

    .line 33554477
    .line 33554478
    .line 33554479
    move-result v0

    .line 33554480
    if-eqz v0, :cond_b

    .line 33554481
    .line 33554482
    const/4 v9, 0x0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_7

    .line 33554483
    :try_start_1
    new-instance v3, Ljava/io/FileInputStream;

    .line 33554484
    .line 33554485
    invoke-direct {v3, p0}, Ljava/io/FileInputStream;-><init>(Ljava/lang/String;)V
    :try_end_1
    .catch Ljava/io/FileNotFoundException; {:try_start_1 .. :try_end_1} :catch_7
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_7
    .catchall {:try_start_1 .. :try_end_1} :catchall_3

    .line 33554486
    .line 33554487
    .line 33554488
    :try_start_2
    new-instance v2, Ljava/io/FileOutputStream;

    .line 33554489
    .line 33554490
    invoke-direct {v2, p1}, Ljava/io/FileOutputStream;-><init>(Ljava/lang/String;)V
    :try_end_2
    .catch Ljava/io/FileNotFoundException; {:try_start_2 .. :try_end_2} :catch_4
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_2

    .line 33554491
    .line 33554492
    .line 33554493
    :try_start_3
    invoke-virtual {v3}, Ljava/io/FileInputStream;->getChannel()Ljava/nio/channels/FileChannel;

    .line 33554494
    .line 33554495
    .line 33554496
    move-result-object v4
    :try_end_3
    .catch Ljava/io/FileNotFoundException; {:try_start_3 .. :try_end_3} :catch_5
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    .line 33554497
    :try_start_4
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->getChannel()Ljava/nio/channels/FileChannel;

    .line 33554498
    .line 33554499
    .line 33554500
    move-result-object v9

    .line 33554501
    const-wide/16 v5, 0x0

    .line 33554502
    .line 33554503
    invoke-virtual {v4}, Ljava/nio/channels/FileChannel;->size()J

    .line 33554504
    .line 33554505
    .line 33554506
    move-result-wide v7

    .line 33554507
    invoke-virtual/range {v4 .. v9}, Ljava/nio/channels/FileChannel;->transferTo(JJLjava/nio/channels/WritableByteChannel;)J
    :try_end_4
    .catch Ljava/io/FileNotFoundException; {:try_start_4 .. :try_end_4} :catch_1
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_0
    .catchall {:try_start_4 .. :try_end_4} :catchall_0

    .line 33554508
    .line 33554509
    .line 33554510
    :try_start_5
    invoke-virtual {v3}, Ljava/io/FileInputStream;->close()V

    .line 33554511
    .line 33554512
    .line 33554513
    invoke-virtual {v4}, Ljava/nio/channels/spi/AbstractInterruptibleChannel;->close()V

    .line 33554514
    .line 33554515
    .line 33554516
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->close()V

    .line 33554517
    .line 33554518
    .line 33554519
    if-eqz v9, :cond_b

    .line 33554520
    .line 33554521
    invoke-virtual {v9}, Ljava/nio/channels/spi/AbstractInterruptibleChannel;->close()V

    .line 33554522
    .line 33554523
    .line 33554524
    return-void
    :try_end_5
    .catch Ljava/io/IOException; {:try_start_5 .. :try_end_5} :catch_7

    .line 33554525
    :catchall_0
    move-exception v0

    .line 33554526
    move-object v1, v9

    .line 33554527
    move-object v9, v4

    .line 33554528
    goto :goto_1

    .line 33554529
    :catch_0
    move-object v0, v9

    .line 33554530
    move-object v9, v4

    .line 33554531
    goto :goto_2

    .line 33554532
    :catch_1
    move-object v0, v9

    .line 33554533
    move-object v9, v4

    .line 33554534
    goto :goto_3

    .line 33554535
    :catchall_1
    move-exception v0

    .line 33554536
    goto :goto_0

    .line 33554537
    :catchall_2
    move-exception v0

    .line 33554538
    move-object v2, v9

    .line 33554539
    :goto_0
    move-object v1, v9

    .line 33554540
    if-eqz v3, :cond_1

    .line 33554541
    .line 33554542
    :goto_1
    :try_start_6
    invoke-virtual {v3}, Ljava/io/FileInputStream;->close()V

    .line 33554543
    .line 33554544
    .line 33554545
    :cond_1
    if-eqz v9, :cond_2

    .line 33554546
    .line 33554547
    invoke-virtual {v9}, Ljava/nio/channels/spi/AbstractInterruptibleChannel;->close()V

    .line 33554548
    .line 33554549
    .line 33554550
    :cond_2
    if-eqz v2, :cond_3

    .line 33554551
    .line 33554552
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->close()V

    .line 33554553
    .line 33554554
    .line 33554555
    :cond_3
    if-eqz v1, :cond_a

    .line 33554556
    .line 33554557
    invoke-virtual {v1}, Ljava/nio/channels/spi/AbstractInterruptibleChannel;->close()V
    :try_end_6
    .catch Ljava/io/IOException; {:try_start_6 .. :try_end_6} :catch_6

    .line 33554558
    .line 33554559
    .line 33554560
    throw v0

    .line 33554561
    :catch_2
    move-object v2, v9

    .line 33554562
    :catch_3
    move-object v0, v9

    .line 33554563
    if-eqz v3, :cond_4

    .line 33554564
    .line 33554565
    :goto_2
    :try_start_7
    invoke-virtual {v3}, Ljava/io/FileInputStream;->close()V

    .line 33554566
    .line 33554567
    .line 33554568
    :cond_4
    if-eqz v9, :cond_5

    .line 33554569
    .line 33554570
    invoke-virtual {v9}, Ljava/nio/channels/spi/AbstractInterruptibleChannel;->close()V

    .line 33554571
    .line 33554572
    .line 33554573
    :cond_5
    if-eqz v2, :cond_6

    .line 33554574
    .line 33554575
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->close()V

    .line 33554576
    .line 33554577
    .line 33554578
    :cond_6
    if-eqz v0, :cond_b

    .line 33554579
    .line 33554580
    goto :goto_4
    :try_end_7
    .catch Ljava/io/IOException; {:try_start_7 .. :try_end_7} :catch_7

    .line 33554581
    :catch_4
    move-object v2, v9

    .line 33554582
    :catch_5
    move-object v0, v9

    .line 33554583
    if-eqz v3, :cond_7

    .line 33554584
    .line 33554585
    :goto_3
    :try_start_8
    invoke-virtual {v3}, Ljava/io/FileInputStream;->close()V

    .line 33554586
    .line 33554587
    .line 33554588
    :cond_7
    if-eqz v9, :cond_8

    .line 33554589
    .line 33554590
    invoke-virtual {v9}, Ljava/nio/channels/spi/AbstractInterruptibleChannel;->close()V

    .line 33554591
    .line 33554592
    .line 33554593
    :cond_8
    if-eqz v2, :cond_9

    .line 33554594
    .line 33554595
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->close()V

    .line 33554596
    .line 33554597
    .line 33554598
    :cond_9
    if-eqz v0, :cond_b

    .line 33554599
    .line 33554600
    :goto_4
    invoke-virtual {v0}, Ljava/nio/channels/spi/AbstractInterruptibleChannel;->close()V

    .line 33554601
    .line 33554602
    .line 33554603
    return-void
    :try_end_8
    .catch Ljava/io/IOException; {:try_start_8 .. :try_end_8} :catch_7

    .line 33554604
    :catchall_3
    move-exception v0

    .line 33554605
    :catch_6
    :cond_a
    throw v0

    .line 33554606
    :catch_7
    :cond_b
    return-void
.end method

.method public static LIZJ(Ljava/lang/String;Z)V
    .locals 3

    .prologue
    .line 33554432
    if-eqz p0, :cond_0

    .line 33554433
    .line 33554434
    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 33554435
    .line 33554436
    .line 33554437
    move-result v0

    .line 33554438
    if-nez v0, :cond_0

    .line 33554439
    .line 33554440
    new-instance v2, Ljava/io/File;

    .line 33554441
    .line 33554442
    invoke-direct {v2, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554443
    .line 33554444
    .line 33554445
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    .line 33554446
    .line 33554447
    .line 33554448
    move-result v0

    .line 33554449
    if-nez v0, :cond_0

    .line 33554450
    .line 33554451
    if-nez p1, :cond_1

    .line 33554452
    .line 33554453
    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z

    .line 33554454
    .line 33554455
    .line 33554456
    :catch_0
    :cond_0
    return-void

    .line 33554457
    :cond_1
    :try_start_0
    invoke-virtual {v2}, Ljava/io/File;->getParentFile()Ljava/io/File;

    .line 33554458
    .line 33554459
    .line 33554460
    move-result-object v1

    .line 33554461
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    .line 33554462
    .line 33554463
    .line 33554464
    move-result v0

    .line 33554465
    if-nez v0, :cond_2

    .line 33554466
    .line 33554467
    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    .line 33554468
    .line 33554469
    .line 33554470
    :cond_2
    invoke-virtual {v2}, Ljava/io/File;->createNewFile()Z

    .line 33554471
    .line 33554472
    .line 33554473
    return-void
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0
.end method

.method public static LIZLLL(Landroid/content/Context;)Ljava/lang/String;
    .locals 2

    .prologue
    .line 16777216
    if-nez p0, :cond_0

    .line 16777217
    .line 16777218
    const-string v0, ""

    .line 16777219
    .line 16777220
    return-object v0

    .line 16777221
    :cond_0
    sget-object v1, LX/DG6;->LIZ:Ljava/lang/String;

    .line 16777222
    .line 16777223
    if-eqz v1, :cond_1

    .line 16777224
    .line 16777225
    invoke-virtual {v1}, Ljava/lang/String;->length()I

    .line 16777226
    .line 16777227
    .line 16777228
    move-result v0

    .line 16777229
    if-eqz v0, :cond_1

    .line 16777230
    .line 16777231
    return-object v1

    .line 16777232
    :cond_1
    sget-object v0, LX/D7F;->PREFER_PRIVATE:LX/D7F;

    .line 16777233
    .line 16777234
    invoke-static {p0, v0}, LX/D7B;->LJII(Landroid/content/Context;LX/D7F;)Ljava/io/File;

    .line 16777235
    .line 16777236
    .line 16777237
    move-result-object v0

    .line 16777238
    if-eqz v0, :cond_3

    .line 16777239
    .line 16777240
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 16777241
    .line 16777242
    .line 16777243
    move-result-object v1

    .line 16777244
    :cond_2
    :goto_0
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 16777245
    .line 16777246
    .line 16777247
    move-result-object p0

    .line 16777248
    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777249
    .line 16777250
    .line 16777251
    const-string v0, "/share/"

    .line 16777252
    .line 16777253
    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777254
    .line 16777255
    .line 16777256
    invoke-static {p0}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 16777257
    .line 16777258
    .line 16777259
    move-result-object v0

    .line 16777260
    sput-object v0, LX/DG6;->LIZ:Ljava/lang/String;

    .line 16777261
    .line 16777262
    return-object v0

    .line 16777263
    :cond_3
    const/4 v1, 0x0

    .line 16777264
    invoke-static {p0, v1}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 16777265
    .line 16777266
    .line 16777267
    move-result-object v0

    .line 16777268
    if-nez v0, :cond_4

    .line 16777269
    .line 16777270
    invoke-static {}, LX/ccj;->G()Ljava/io/File;

    .line 16777271
    .line 16777272
    .line 16777273
    move-result-object v0

    .line 16777274
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 16777275
    .line 16777276
    .line 16777277
    move-result-object v1

    .line 16777278
    goto :goto_0

    .line 16777279
    :cond_4
    invoke-static {p0, v1}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 16777280
    .line 16777281
    .line 16777282
    move-result-object v0

    .line 16777283
    if-eqz v0, :cond_2

    .line 16777284
    .line 16777285
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 16777286
    .line 16777287
    .line 16777288
    move-result-object v1

    .line 16777289
    goto :goto_0
.end method

.method public static LJ(Ljava/lang/String;)V
    .locals 3

    .prologue
    .line 16777216
    sget-boolean v0, LX/DG6;->isNeedGuard:Z

    .line 16777217
    .line 16777218
    const/4 v2, 0x0

    .line 16777219
    if-eqz v0, :cond_0

    .line 16777220
    .line 16777221
    const/4 v0, 0x1

    .line 16777222
    new-array v0, v0, [Ljava/lang/Object;

    .line 16777223
    .line 16777224
    aput-object p0, v0, v2

    .line 16777225
    .line 16777226
    const/16 v1, 0x66

    .line 16777227
    .line 16777228
    invoke-static {v1, v0}, Lcom/bytedance/tt/lifeguard/Lifeguard;->intercept(I[Ljava/lang/Object;)Z

    .line 16777229
    .line 16777230
    .line 16777231
    move-result v0

    .line 16777232
    if-eqz v0, :cond_0

    .line 16777233
    .line 16777234
    invoke-static {v1}, Lcom/bytedance/tt/lifeguard/Lifeguard;->earlyReturn(I)Ljava/lang/Object;

    .line 16777235
    .line 16777236
    .line 16777237
    move-result-object v0

    .line 16777238
    check-cast v0, Ljava/lang/Boolean;

    .line 16777239
    .line 16777240
    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    .line 16777241
    .line 16777242
    .line 16777243
    return-void

    .line 16777244
    :cond_0
    if-eqz p0, :cond_1

    .line 16777245
    .line 16777246
    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    .line 16777247
    .line 16777248
    .line 16777249
    move-result v0

    .line 16777250
    if-nez v0, :cond_1

    .line 16777251
    .line 16777252
    :try_start_0
    const-string v1, "mounted"

    .line 16777253
    .line 16777254
    invoke-static {}, LX/ccj;->H()Ljava/lang/String;

    .line 16777255
    .line 16777256
    .line 16777257
    move-result-object v0

    .line 16777258
    invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->LJ(Ljava/lang/Object;Ljava/lang/Object;)Z

    .line 16777259
    .line 16777260
    .line 16777261
    move-result v2
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 16777262
    :catch_0
    if-eqz v2, :cond_1

    .line 16777263
    .line 16777264
    new-instance v1, Ljava/io/File;

    .line 16777265
    .line 16777266
    invoke-direct {v1, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 16777267
    .line 16777268
    .line 16777269
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    .line 16777270
    .line 16777271
    .line 16777272
    move-result v0

    .line 16777273
    if-eqz v0, :cond_1

    .line 16777274
    .line 16777275
    invoke-static {v1}, LX/ccj;->v2(Ljava/io/File;)Z

    .line 16777276
    .line 16777277
    .line 16777278
    :cond_1
    return-void
.end method
