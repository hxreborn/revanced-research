.class public final LX/Cne;
.super Ljava/lang/Object;
.source "SourceFile"


# static fields
.field public static volatile LIZ:Z

.field public static LIZIZ:Ljava/lang/String;

.field public static LIZJ:Ljava/lang/String;

.field public static LIZLLL:Ljava/io/File;

.field public static LJ:Ljava/io/File;

.field public static volatile isNeedGuard:Z


# direct methods
.method public static LIZ(ILandroid/content/Context;)V
    .locals 2

    .prologue
    .line 33554432
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 33554433
    .line 33554434
    .line 33554435
    move-result-object v1

    .line 33554436
    const-string v0, "clearDraftsV2 "

    .line 33554437
    .line 33554438
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554439
    .line 33554440
    .line 33554441
    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    .line 33554442
    .line 33554443
    .line 33554444
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 33554445
    .line 33554446
    .line 33554447
    if-eqz p1, :cond_1

    .line 33554448
    .line 33554449
    invoke-static {p1}, LX/ccj;->LLLLIIL(Landroid/content/Context;)Ljava/io/File;

    .line 33554450
    .line 33554451
    .line 33554452
    move-result-object v0

    .line 33554453
    if-eqz v0, :cond_0

    .line 33554454
    .line 33554455
    invoke-static {p1}, LX/ccj;->LLLLIIL(Landroid/content/Context;)Ljava/io/File;

    .line 33554456
    .line 33554457
    .line 33554458
    move-result-object v0

    .line 33554459
    invoke-static {p0, v0}, LX/Cne;->LJIIIZ(ILjava/io/File;)Ljava/util/List;

    .line 33554460
    .line 33554461
    .line 33554462
    move-result-object v0

    .line 33554463
    invoke-static {v0}, LX/Cne;->LJ(Ljava/util/List;)V

    .line 33554464
    .line 33554465
    .line 33554466
    :cond_0
    const/4 v1, 0x0

    .line 33554467
    :try_start_0
    invoke-static {p1, v1}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 33554468
    .line 33554469
    .line 33554470
    move-result-object v0

    .line 33554471
    if-eqz v0, :cond_1

    .line 33554472
    .line 33554473
    invoke-static {p1, v1}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 33554474
    .line 33554475
    .line 33554476
    move-result-object v0

    .line 33554477
    invoke-static {p0, v0}, LX/Cne;->LJIIIZ(ILjava/io/File;)Ljava/util/List;

    .line 33554478
    .line 33554479
    .line 33554480
    move-result-object v0

    .line 33554481
    invoke-static {v0}, LX/Cne;->LJ(Ljava/util/List;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 33554482
    .line 33554483
    .line 33554484
    :catch_0
    :cond_1
    return-void
.end method

.method public static LIZIZ(I)V
    .locals 4

    .prologue
    .line 16777216
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 16777217
    .line 16777218
    .line 16777219
    move-result-object v1

    .line 16777220
    const-string v0, "clearDuetFiles "

    .line 16777221
    .line 16777222
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777223
    .line 16777224
    .line 16777225
    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    .line 16777226
    .line 16777227
    .line 16777228
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 16777229
    .line 16777230
    .line 16777231
    const/4 v3, 0x0

    .line 16777232
    :try_start_0
    invoke-static {}, Lcom/ss/android/ugc/aweme/out/AVExternalServiceImpl;->LIZ()Lcom/ss/android/ugc/aweme/services/IExternalService;

    .line 16777233
    .line 16777234
    .line 16777235
    move-result-object v0

    .line 16777236
    invoke-interface {v0}, Lcom/ss/android/ugc/aweme/services/IExternalService;->configService()Lcom/ss/android/ugc/aweme/services/external/IConfigService;

    .line 16777237
    .line 16777238
    .line 16777239
    move-result-object v0

    .line 16777240
    invoke-interface {v0}, Lcom/ss/android/ugc/aweme/services/external/IConfigService;->cacheConfig()Lcom/ss/android/ugc/aweme/services/external/ICacheService;

    .line 16777241
    .line 16777242
    .line 16777243
    move-result-object v2

    .line 16777244
    if-eqz v2, :cond_0

    .line 16777245
    .line 16777246
    mul-int/lit8 v0, p0, 0x2
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 16777247
    .line 16777248
    :try_start_1
    invoke-interface {v2}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->tempDuetFile()[Ljava/io/File;

    .line 16777249
    .line 16777250
    .line 16777251
    move-result-object v1

    .line 16777252
    goto :goto_0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 16777253
    :catchall_0
    move-object v1, v3

    .line 16777254
    :goto_0
    mul-int/lit8 v0, v0, 0x2

    .line 16777255
    .line 16777256
    invoke-static {v1, v0}, LX/Cne;->LJIL([Ljava/io/File;I)Ljava/util/List;

    .line 16777257
    .line 16777258
    .line 16777259
    move-result-object v0

    .line 16777260
    invoke-static {v0}, LX/Cne;->LIZLLL(Ljava/util/List;)V

    .line 16777261
    .line 16777262
    .line 16777263
    :try_start_2
    invoke-interface {v2}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->rawDuetFile()[Ljava/io/File;

    .line 16777264
    .line 16777265
    .line 16777266
    move-result-object v3
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    .line 16777267
    :catchall_1
    invoke-static {v3, p0}, LX/Cne;->LJIL([Ljava/io/File;I)Ljava/util/List;

    .line 16777268
    .line 16777269
    .line 16777270
    move-result-object v0

    .line 16777271
    invoke-static {v0}, LX/Cne;->LJ(Ljava/util/List;)V

    .line 16777272
    .line 16777273
    .line 16777274
    return-void

    .line 16777275
    :catch_0
    :cond_0
    return-void
.end method

.method public static LIZJ(ILandroid/content/Context;)V
    .locals 5

    .prologue
    .line 33554432
    const/4 v1, 0x0

    .line 33554433
    :try_start_0
    sget-object v0, LX/BFb;->LIZIZ:LX/BFb;

    .line 33554434
    .line 33554435
    iget-object v0, v0, LX/BFb;->LIZ:Lcom/ss/android/ugc/aweme/global/config/settings/pojo/IESSettingsProxy;

    .line 33554436
    .line 33554437
    invoke-virtual {v0}, Lcom/ss/android/ugc/aweme/global/config/settings/pojo/IESSettingsProxy;->getCleanShareFiles()Ljava/lang/Boolean;

    .line 33554438
    .line 33554439
    .line 33554440
    move-result-object v0

    .line 33554441
    if-eqz v0, :cond_0
    :try_end_0
    .catch LX/AUR; {:try_start_0 .. :try_end_0} :catch_0

    .line 33554442
    .line 33554443
    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    .line 33554444
    .line 33554445
    .line 33554446
    move-result v0

    .line 33554447
    if-eqz v0, :cond_0

    .line 33554448
    .line 33554449
    const/4 p0, 0x0

    .line 33554450
    :catch_0
    :cond_0
    if-nez p1, :cond_1

    .line 33554451
    .line 33554452
    return-void

    .line 33554453
    :cond_1
    invoke-static {p0, p1}, LX/Cne;->LJIJI(ILandroid/content/Context;)Ljava/util/List;

    .line 33554454
    .line 33554455
    .line 33554456
    move-result-object v0

    .line 33554457
    invoke-static {v0}, LX/Cne;->LIZLLL(Ljava/util/List;)V

    .line 33554458
    .line 33554459
    .line 33554460
    new-instance v4, Ljava/io/File;

    .line 33554461
    .line 33554462
    invoke-static {p1}, LX/Cne;->LJIILJJIL(Landroid/content/Context;)Ljava/lang/String;

    .line 33554463
    .line 33554464
    .line 33554465
    move-result-object v0

    .line 33554466
    invoke-direct {v4, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554467
    .line 33554468
    .line 33554469
    new-instance v2, Ljava/io/File;

    .line 33554470
    .line 33554471
    invoke-static {p1, v1}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 33554472
    .line 33554473
    .line 33554474
    move-result-object v0

    .line 33554475
    const-string v3, "share"

    .line 33554476
    .line 33554477
    invoke-direct {v2, v0, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 33554478
    .line 33554479
    .line 33554480
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    .line 33554481
    .line 33554482
    .line 33554483
    move-result v0

    .line 33554484
    if-eqz v0, :cond_2

    .line 33554485
    .line 33554486
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 33554487
    .line 33554488
    .line 33554489
    move-result-object v1

    .line 33554490
    invoke-virtual {v4}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 33554491
    .line 33554492
    .line 33554493
    move-result-object v0

    .line 33554494
    invoke-static {v1, v0}, Landroid/text/TextUtils;->equals(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Z

    .line 33554495
    .line 33554496
    .line 33554497
    move-result v0

    .line 33554498
    if-nez v0, :cond_2

    .line 33554499
    .line 33554500
    invoke-static {p0, v2}, LX/Cne;->LJJ(ILjava/io/File;)V

    .line 33554501
    .line 33554502
    .line 33554503
    :cond_2
    invoke-static {p1}, LX/D7B;->LJIIIZ(Landroid/content/Context;)Ljava/io/File;

    .line 33554504
    .line 33554505
    .line 33554506
    move-result-object v0

    .line 33554507
    if-eqz v0, :cond_3

    .line 33554508
    .line 33554509
    new-instance v2, Ljava/io/File;

    .line 33554510
    .line 33554511
    invoke-direct {v2, v0, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 33554512
    .line 33554513
    .line 33554514
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    .line 33554515
    .line 33554516
    .line 33554517
    move-result v0

    .line 33554518
    if-eqz v0, :cond_3

    .line 33554519
    .line 33554520
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 33554521
    .line 33554522
    .line 33554523
    move-result-object v1

    .line 33554524
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 33554525
    .line 33554526
    .line 33554527
    move-result-object v0

    .line 33554528
    invoke-static {v1, v0}, Landroid/text/TextUtils;->equals(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Z

    .line 33554529
    .line 33554530
    .line 33554531
    move-result v0

    .line 33554532
    if-nez v0, :cond_3

    .line 33554533
    .line 33554534
    invoke-static {p0, v2}, LX/Cne;->LJJ(ILjava/io/File;)V

    .line 33554535
    .line 33554536
    .line 33554537
    :cond_3
    return-void
.end method

.method public static LIZLLL(Ljava/util/List;)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/io/File;",
            ">;)V"
        }
    .end annotation

    .prologue
    .line 16777216
    sget-boolean v1, LX/Cne;->isNeedGuard:Z

    .line 16777217
    .line 16777218
    const/4 v2, 0x0

    .line 16777219
    const/4 v0, 0x1

    .line 16777220
    if-eqz v1, :cond_0

    .line 16777221
    .line 16777222
    new-array v1, v0, [Ljava/lang/Object;

    .line 16777223
    .line 16777224
    aput-object p0, v1, v2

    .line 16777225
    .line 16777226
    const/16 v0, 0xa46

    .line 16777227
    .line 16777228
    invoke-static {v0, v1}, Lcom/bytedance/tt/lifeguard/Lifeguard;->intercept(I[Ljava/lang/Object;)Z

    .line 16777229
    .line 16777230
    .line 16777231
    move-result v0

    .line 16777232
    if-eqz v0, :cond_0

    .line 16777233
    .line 16777234
    return-void

    .line 16777235
    :cond_0
    if-eqz p0, :cond_3

    .line 16777236
    .line 16777237
    invoke-interface {p0}, Ljava/util/List;->size()I

    .line 16777238
    .line 16777239
    .line 16777240
    move-result v0

    .line 16777241
    if-lez v0, :cond_3

    .line 16777242
    .line 16777243
    invoke-interface {p0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    .line 16777244
    .line 16777245
    .line 16777246
    move-result-object v2

    .line 16777247
    :cond_1
    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    .line 16777248
    .line 16777249
    .line 16777250
    move-result v0

    .line 16777251
    if-eqz v0, :cond_3

    .line 16777252
    .line 16777253
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 16777254
    .line 16777255
    .line 16777256
    move-result-object v1

    .line 16777257
    check-cast v1, Ljava/io/File;

    .line 16777258
    .line 16777259
    if-eqz v1, :cond_1

    .line 16777260
    .line 16777261
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    .line 16777262
    .line 16777263
    .line 16777264
    move-result v0

    .line 16777265
    if-eqz v0, :cond_1

    .line 16777266
    .line 16777267
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 16777268
    .line 16777269
    .line 16777270
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 16777271
    .line 16777272
    .line 16777273
    move-result-object v0

    .line 16777274
    invoke-static {v0}, Lcom/bytedance/refcache/FileLocker;->getStatus(Ljava/lang/String;)I

    .line 16777275
    .line 16777276
    .line 16777277
    move-result v0

    .line 16777278
    if-ltz v0, :cond_2

    .line 16777279
    .line 16777280
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 16777281
    .line 16777282
    .line 16777283
    goto :goto_0

    .line 16777284
    :cond_2
    invoke-static {v1}, LX/ccj;->v2(Ljava/io/File;)Z

    .line 16777285
    .line 16777286
    .line 16777287
    goto :goto_0

    .line 16777288
    :cond_3
    return-void
.end method

.method public static LJ(Ljava/util/List;)V
    .locals 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/io/File;",
            ">;)V"
        }
    .end annotation

    .prologue
    .line 16777216
    sget-boolean v1, LX/Cne;->isNeedGuard:Z

    .line 16777217
    .line 16777218
    const/4 v2, 0x0

    .line 16777219
    const/4 v0, 0x1

    .line 16777220
    if-eqz v1, :cond_0

    .line 16777221
    .line 16777222
    new-array v1, v0, [Ljava/lang/Object;

    .line 16777223
    .line 16777224
    aput-object p0, v1, v2

    .line 16777225
    .line 16777226
    const/16 v0, 0xa4a

    .line 16777227
    .line 16777228
    invoke-static {v0, v1}, Lcom/bytedance/tt/lifeguard/Lifeguard;->intercept(I[Ljava/lang/Object;)Z

    .line 16777229
    .line 16777230
    .line 16777231
    move-result v0

    .line 16777232
    if-eqz v0, :cond_0

    .line 16777233
    .line 16777234
    return-void

    .line 16777235
    :cond_0
    if-eqz p0, :cond_3

    .line 16777236
    .line 16777237
    invoke-interface {p0}, Ljava/util/List;->size()I

    .line 16777238
    .line 16777239
    .line 16777240
    move-result v0

    .line 16777241
    if-lez v0, :cond_3

    .line 16777242
    .line 16777243
    invoke-static {}, LX/Cne;->LJIIL()Ljava/util/Set;

    .line 16777244
    .line 16777245
    .line 16777246
    move-result-object v4

    .line 16777247
    invoke-interface {p0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    .line 16777248
    .line 16777249
    .line 16777250
    move-result-object v3

    .line 16777251
    :cond_1
    :goto_0
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    .line 16777252
    .line 16777253
    .line 16777254
    move-result v0

    .line 16777255
    if-eqz v0, :cond_3

    .line 16777256
    .line 16777257
    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 16777258
    .line 16777259
    .line 16777260
    move-result-object v2

    .line 16777261
    check-cast v2, Ljava/io/File;

    .line 16777262
    .line 16777263
    if-eqz v2, :cond_1

    .line 16777264
    .line 16777265
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    .line 16777266
    .line 16777267
    .line 16777268
    move-result v0

    .line 16777269
    if-eqz v0, :cond_1

    .line 16777270
    .line 16777271
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 16777272
    .line 16777273
    .line 16777274
    move-result-object v1

    .line 16777275
    move-object v0, v4

    .line 16777276
    check-cast v0, Ljava/util/HashSet;

    .line 16777277
    .line 16777278
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z

    .line 16777279
    .line 16777280
    .line 16777281
    move-result v0

    .line 16777282
    if-nez v0, :cond_1

    .line 16777283
    .line 16777284
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 16777285
    .line 16777286
    .line 16777287
    move-result-object v0

    .line 16777288
    invoke-static {v0}, Lcom/bytedance/refcache/FileLocker;->getStatus(Ljava/lang/String;)I

    .line 16777289
    .line 16777290
    .line 16777291
    move-result v0

    .line 16777292
    if-ltz v0, :cond_2

    .line 16777293
    .line 16777294
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 16777295
    .line 16777296
    .line 16777297
    goto :goto_0

    .line 16777298
    :cond_2
    invoke-static {v2}, LX/ccj;->v2(Ljava/io/File;)Z

    .line 16777299
    .line 16777300
    .line 16777301
    goto :goto_0

    .line 16777302
    :cond_3
    return-void
.end method

.method public static LJFF(Landroid/content/Context;)Ljava/io/File;
    .locals 3

    .prologue
    .line 16777216
    sget-object v0, LX/Cne;->LJ:Ljava/io/File;

    .line 16777217
    .line 16777218
    if-eqz v0, :cond_0

    .line 16777219
    .line 16777220
    return-object v0

    .line 16777221
    :cond_0
    sget-object v0, LX/D7F;->PREFER_SD_CARD:LX/D7F;

    .line 16777222
    .line 16777223
    invoke-static {p0, v0}, LX/D7B;->LJII(Landroid/content/Context;LX/D7F;)Ljava/io/File;

    .line 16777224
    .line 16777225
    .line 16777226
    move-result-object v0

    .line 16777227
    const-string v2, "logs"

    .line 16777228
    .line 16777229
    if-nez v0, :cond_3

    .line 16777230
    .line 16777231
    :try_start_0
    invoke-static {p0, v2}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 16777232
    .line 16777233
    .line 16777234
    move-result-object v0

    .line 16777235
    sput-object v0, LX/Cne;->LJ:Ljava/io/File;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 16777236
    .line 16777237
    :catch_0
    sget-object v0, LX/Cne;->LJ:Ljava/io/File;

    .line 16777238
    .line 16777239
    if-nez v0, :cond_1

    .line 16777240
    .line 16777241
    new-instance v1, Ljava/io/File;

    .line 16777242
    .line 16777243
    invoke-static {p0}, LX/ccj;->LLLLIIL(Landroid/content/Context;)Ljava/io/File;

    .line 16777244
    .line 16777245
    .line 16777246
    move-result-object v0

    .line 16777247
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 16777248
    .line 16777249
    .line 16777250
    sput-object v1, LX/Cne;->LJ:Ljava/io/File;

    .line 16777251
    .line 16777252
    :cond_1
    sget-object v0, LX/Cne;->LJ:Ljava/io/File;

    .line 16777253
    .line 16777254
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    .line 16777255
    .line 16777256
    .line 16777257
    move-result v0

    .line 16777258
    if-nez v0, :cond_2

    .line 16777259
    .line 16777260
    sget-object v0, LX/Cne;->LJ:Ljava/io/File;

    .line 16777261
    .line 16777262
    invoke-virtual {v0}, Ljava/io/File;->mkdirs()Z

    .line 16777263
    .line 16777264
    .line 16777265
    :cond_2
    sget-object v0, LX/Cne;->LJ:Ljava/io/File;

    .line 16777266
    .line 16777267
    return-object v0

    .line 16777268
    :cond_3
    new-instance v1, Ljava/io/File;

    .line 16777269
    .line 16777270
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 16777271
    .line 16777272
    .line 16777273
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    .line 16777274
    .line 16777275
    .line 16777276
    move-result v0

    .line 16777277
    if-nez v0, :cond_4

    .line 16777278
    .line 16777279
    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    .line 16777280
    .line 16777281
    .line 16777282
    :cond_4
    sput-object v1, LX/Cne;->LJ:Ljava/io/File;

    .line 16777283
    .line 16777284
    return-object v1
.end method

.method public static LJI(Ljava/util/List;)J
    .locals 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/io/File;",
            ">;)J"
        }
    .end annotation

    .prologue
    .line 16777216
    const-wide/16 v3, 0x0

    .line 16777217
    .line 16777218
    if-eqz p0, :cond_1

    .line 16777219
    .line 16777220
    invoke-interface {p0}, Ljava/util/List;->size()I

    .line 16777221
    .line 16777222
    .line 16777223
    move-result v0

    .line 16777224
    if-lez v0, :cond_1

    .line 16777225
    .line 16777226
    invoke-interface {p0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    .line 16777227
    .line 16777228
    .line 16777229
    move-result-object v2

    .line 16777230
    :cond_0
    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    .line 16777231
    .line 16777232
    .line 16777233
    move-result v0

    .line 16777234
    if-eqz v0, :cond_1

    .line 16777235
    .line 16777236
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 16777237
    .line 16777238
    .line 16777239
    move-result-object v1

    .line 16777240
    check-cast v1, Ljava/io/File;

    .line 16777241
    .line 16777242
    if-eqz v1, :cond_0

    .line 16777243
    .line 16777244
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    .line 16777245
    .line 16777246
    .line 16777247
    move-result v0

    .line 16777248
    if-eqz v0, :cond_0

    .line 16777249
    .line 16777250
    invoke-virtual {v1}, Ljava/io/File;->length()J

    .line 16777251
    .line 16777252
    .line 16777253
    move-result-wide v0

    .line 16777254
    add-long/2addr v3, v0

    .line 16777255
    goto :goto_0

    .line 16777256
    :cond_1
    return-wide v3
.end method

.method public static LJII(Ljava/util/List;)J
    .locals 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/io/File;",
            ">;)J"
        }
    .end annotation

    .prologue
    .line 16777216
    const-wide/16 v5, 0x0

    .line 16777217
    .line 16777218
    if-eqz p0, :cond_2

    .line 16777219
    .line 16777220
    invoke-interface {p0}, Ljava/util/List;->size()I

    .line 16777221
    .line 16777222
    .line 16777223
    move-result v0

    .line 16777224
    if-lez v0, :cond_2

    .line 16777225
    .line 16777226
    invoke-static {}, LX/Cne;->LJIIL()Ljava/util/Set;

    .line 16777227
    .line 16777228
    .line 16777229
    move-result-object v4

    .line 16777230
    invoke-interface {p0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    .line 16777231
    .line 16777232
    .line 16777233
    move-result-object v3

    .line 16777234
    :cond_0
    :goto_0
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    .line 16777235
    .line 16777236
    .line 16777237
    move-result v0

    .line 16777238
    if-eqz v0, :cond_2

    .line 16777239
    .line 16777240
    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 16777241
    .line 16777242
    .line 16777243
    move-result-object v2

    .line 16777244
    check-cast v2, Ljava/io/File;

    .line 16777245
    .line 16777246
    if-eqz v2, :cond_0

    .line 16777247
    .line 16777248
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    .line 16777249
    .line 16777250
    .line 16777251
    move-result v0

    .line 16777252
    if-eqz v0, :cond_0

    .line 16777253
    .line 16777254
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 16777255
    .line 16777256
    .line 16777257
    move-result-object v1

    .line 16777258
    move-object v0, v4

    .line 16777259
    check-cast v0, Ljava/util/HashSet;

    .line 16777260
    .line 16777261
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z

    .line 16777262
    .line 16777263
    .line 16777264
    move-result v0

    .line 16777265
    if-nez v0, :cond_0

    .line 16777266
    .line 16777267
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 16777268
    .line 16777269
    .line 16777270
    move-result-object v0

    .line 16777271
    invoke-static {v0}, Lcom/bytedance/refcache/FileLocker;->getStatus(Ljava/lang/String;)I

    .line 16777272
    .line 16777273
    .line 16777274
    move-result v0

    .line 16777275
    if-ltz v0, :cond_1

    .line 16777276
    .line 16777277
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 16777278
    .line 16777279
    .line 16777280
    move-result-object v1

    .line 16777281
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 16777282
    .line 16777283
    .line 16777284
    move-result-object v0

    .line 16777285
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777286
    .line 16777287
    .line 16777288
    const-string v0, " in use"

    .line 16777289
    .line 16777290
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777291
    .line 16777292
    .line 16777293
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 16777294
    .line 16777295
    .line 16777296
    goto :goto_0

    .line 16777297
    :cond_1
    invoke-virtual {v2}, Ljava/io/File;->length()J

    .line 16777298
    .line 16777299
    .line 16777300
    move-result-wide v0

    .line 16777301
    add-long/2addr v5, v0

    .line 16777302
    goto :goto_0

    .line 16777303
    :cond_2
    return-wide v5
.end method

.method public static LJIIIIZZ(ILandroid/content/Context;)Ljava/util/List;
    .locals 5

    .prologue
    .line 33554432
    new-instance v4, Ljava/util/ArrayList;

    .line 33554433
    .line 33554434
    invoke-direct {v4}, Ljava/util/ArrayList;-><init>()V

    .line 33554435
    .line 33554436
    .line 33554437
    if-eqz p1, :cond_0

    .line 33554438
    .line 33554439
    invoke-static {p1}, LX/ccj;->LLLLIIL(Landroid/content/Context;)Ljava/io/File;

    .line 33554440
    .line 33554441
    .line 33554442
    move-result-object v0

    .line 33554443
    if-eqz v0, :cond_0

    .line 33554444
    .line 33554445
    invoke-static {p1}, LX/ccj;->LLLLIIL(Landroid/content/Context;)Ljava/io/File;

    .line 33554446
    .line 33554447
    .line 33554448
    move-result-object v0

    .line 33554449
    invoke-static {p0, v0}, LX/Cne;->LJIJJ(ILjava/io/File;)Ljava/util/List;

    .line 33554450
    .line 33554451
    .line 33554452
    move-result-object v0

    .line 33554453
    invoke-virtual {v4, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554454
    .line 33554455
    .line 33554456
    :cond_0
    const/4 v3, 0x0

    .line 33554457
    if-eqz p1, :cond_1

    .line 33554458
    .line 33554459
    :try_start_0
    invoke-static {p1, v3}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 33554460
    .line 33554461
    .line 33554462
    move-result-object v0

    .line 33554463
    if-eqz v0, :cond_1

    .line 33554464
    .line 33554465
    invoke-static {p1, v3}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 33554466
    .line 33554467
    .line 33554468
    move-result-object v0

    .line 33554469
    invoke-static {p0, v0}, LX/Cne;->LJIJJ(ILjava/io/File;)Ljava/util/List;

    .line 33554470
    .line 33554471
    .line 33554472
    move-result-object v0

    .line 33554473
    invoke-virtual {v4, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 33554474
    .line 33554475
    .line 33554476
    :catch_0
    :cond_1
    :try_start_1
    invoke-static {}, Lcom/ss/android/ugc/aweme/out/AVExternalServiceImpl;->LIZ()Lcom/ss/android/ugc/aweme/services/IExternalService;

    .line 33554477
    .line 33554478
    .line 33554479
    move-result-object v0

    .line 33554480
    invoke-interface {v0}, Lcom/ss/android/ugc/aweme/services/IExternalService;->configService()Lcom/ss/android/ugc/aweme/services/external/IConfigService;

    .line 33554481
    .line 33554482
    .line 33554483
    move-result-object v0

    .line 33554484
    invoke-interface {v0}, Lcom/ss/android/ugc/aweme/services/external/IConfigService;->cacheConfig()Lcom/ss/android/ugc/aweme/services/external/ICacheService;

    .line 33554485
    .line 33554486
    .line 33554487
    move-result-object v0

    .line 33554488
    goto :goto_0
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    .line 33554489
    :catch_1
    move-object v0, v3

    .line 33554490
    :goto_0
    if-nez v0, :cond_3

    .line 33554491
    .line 33554492
    sget-object v2, Ljava/util/Collections;->EMPTY_LIST:Ljava/util/List;

    .line 33554493
    .line 33554494
    :cond_2
    :goto_1
    invoke-virtual {v4, v2}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554495
    .line 33554496
    .line 33554497
    return-object v4

    .line 33554498
    :cond_3
    new-instance v2, Ljava/util/ArrayList;

    .line 33554499
    .line 33554500
    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    .line 33554501
    .line 33554502
    .line 33554503
    :try_start_2
    invoke-interface {v0}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->compatMusDraftDir()Ljava/lang/String;

    .line 33554504
    .line 33554505
    .line 33554506
    move-result-object v3
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_2

    .line 33554507
    :catch_2
    if-eqz v3, :cond_2

    .line 33554508
    .line 33554509
    new-instance v1, Ljava/io/File;

    .line 33554510
    .line 33554511
    invoke-direct {v1, v3}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554512
    .line 33554513
    .line 33554514
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    .line 33554515
    .line 33554516
    .line 33554517
    move-result v0

    .line 33554518
    if-eqz v0, :cond_2

    .line 33554519
    .line 33554520
    new-instance v0, Ljava/util/ArrayList;

    .line 33554521
    .line 33554522
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 33554523
    .line 33554524
    .line 33554525
    invoke-static {v1, v0}, LX/Cne;->LJIIJ(Ljava/io/File;Ljava/util/List;)V

    .line 33554526
    .line 33554527
    .line 33554528
    invoke-virtual {v2, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554529
    .line 33554530
    .line 33554531
    goto :goto_1
.end method

.method public static LJIIIZ(ILjava/io/File;)Ljava/util/List;
    .locals 4

    .prologue
    .line 33554432
    new-instance v3, Ljava/util/ArrayList;

    .line 33554433
    .line 33554434
    invoke-direct {v3}, Ljava/util/ArrayList;-><init>()V

    .line 33554435
    .line 33554436
    .line 33554437
    new-instance v2, Ljava/io/File;

    .line 33554438
    .line 33554439
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 33554440
    .line 33554441
    .line 33554442
    move-result-object v1

    .line 33554443
    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 33554444
    .line 33554445
    .line 33554446
    move-result-object v0

    .line 33554447
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554448
    .line 33554449
    .line 33554450
    sget-object v0, Ljava/io/File;->separator:Ljava/lang/String;

    .line 33554451
    .line 33554452
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554453
    .line 33554454
    .line 33554455
    const-string v0, "cache"

    .line 33554456
    .line 33554457
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554458
    .line 33554459
    .line 33554460
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 33554461
    .line 33554462
    .line 33554463
    move-result-object v0

    .line 33554464
    invoke-direct {v2, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554465
    .line 33554466
    .line 33554467
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    .line 33554468
    .line 33554469
    .line 33554470
    move-result v0

    .line 33554471
    if-eqz v0, :cond_0

    .line 33554472
    .line 33554473
    new-instance v0, LX/Cnh;

    .line 33554474
    .line 33554475
    invoke-direct {v0}, LX/Cnh;-><init>()V

    .line 33554476
    .line 33554477
    .line 33554478
    invoke-virtual {v2, v0}, Ljava/io/File;->listFiles(Ljava/io/FileFilter;)[Ljava/io/File;

    .line 33554479
    .line 33554480
    .line 33554481
    move-result-object v1

    .line 33554482
    if-eqz v1, :cond_0

    .line 33554483
    .line 33554484
    array-length v0, v1

    .line 33554485
    if-lez v0, :cond_0

    .line 33554486
    .line 33554487
    invoke-static {v1, p0}, LX/Cne;->LJIL([Ljava/io/File;I)Ljava/util/List;

    .line 33554488
    .line 33554489
    .line 33554490
    move-result-object v0

    .line 33554491
    invoke-virtual {v3, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554492
    .line 33554493
    .line 33554494
    :cond_0
    return-object v3
.end method

.method public static LJIIJ(Ljava/io/File;Ljava/util/List;)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/io/File;",
            "Ljava/util/List<",
            "Ljava/io/File;",
            ">;)V"
        }
    .end annotation

    .prologue
    .line 33554432
    if-nez p0, :cond_0

    .line 33554433
    .line 33554434
    return-void

    .line 33554435
    :cond_0
    invoke-virtual {p0}, Ljava/io/File;->isFile()Z

    .line 33554436
    .line 33554437
    .line 33554438
    move-result v0

    .line 33554439
    if-eqz v0, :cond_2

    .line 33554440
    .line 33554441
    check-cast p1, Ljava/util/ArrayList;

    .line 33554442
    .line 33554443
    invoke-virtual {p1, p0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 33554444
    .line 33554445
    .line 33554446
    :cond_1
    return-void

    .line 33554447
    :cond_2
    invoke-virtual {p0}, Ljava/io/File;->listFiles()[Ljava/io/File;

    .line 33554448
    .line 33554449
    .line 33554450
    move-result-object p0

    .line 33554451
    if-eqz p0, :cond_1

    .line 33554452
    .line 33554453
    array-length v0, p0

    .line 33554454
    if-lez v0, :cond_1

    .line 33554455
    .line 33554456
    array-length v2, p0

    .line 33554457
    const/4 v1, 0x0

    .line 33554458
    :goto_0
    if-ge v1, v2, :cond_1

    .line 33554459
    .line 33554460
    aget-object v0, p0, v1

    .line 33554461
    .line 33554462
    invoke-static {v0, p1}, LX/Cne;->LJIIJ(Ljava/io/File;Ljava/util/List;)V

    .line 33554463
    .line 33554464
    .line 33554465
    add-int/lit8 v1, v1, 0x1

    .line 33554466
    .line 33554467
    goto :goto_0
.end method

.method public static LJIIJJI(ILandroid/content/Context;)Ljava/util/List;
    .locals 5

    .prologue
    .line 33554432
    const/4 v3, 0x0

    .line 33554433
    if-eqz p1, :cond_0

    .line 33554434
    .line 33554435
    invoke-static {p1}, LX/ccj;->LLLLIIL(Landroid/content/Context;)Ljava/io/File;

    .line 33554436
    .line 33554437
    .line 33554438
    move-result-object v2

    .line 33554439
    if-eqz v2, :cond_0

    .line 33554440
    .line 33554441
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    .line 33554442
    .line 33554443
    .line 33554444
    move-result v0

    .line 33554445
    if-eqz v0, :cond_0

    .line 33554446
    .line 33554447
    new-instance v3, Ljava/io/File;

    .line 33554448
    .line 33554449
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 33554450
    .line 33554451
    .line 33554452
    move-result-object v1

    .line 33554453
    invoke-virtual {v2}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 33554454
    .line 33554455
    .line 33554456
    move-result-object v0

    .line 33554457
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554458
    .line 33554459
    .line 33554460
    sget-object v0, Ljava/io/File;->separator:Ljava/lang/String;

    .line 33554461
    .line 33554462
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554463
    .line 33554464
    .line 33554465
    const-string v0, "music/download"

    .line 33554466
    .line 33554467
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554468
    .line 33554469
    .line 33554470
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 33554471
    .line 33554472
    .line 33554473
    move-result-object v0

    .line 33554474
    invoke-direct {v3, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554475
    .line 33554476
    .line 33554477
    :cond_0
    new-instance v4, Ljava/util/ArrayList;

    .line 33554478
    .line 33554479
    invoke-direct {v4}, Ljava/util/ArrayList;-><init>()V

    .line 33554480
    .line 33554481
    .line 33554482
    if-eqz v3, :cond_1

    .line 33554483
    .line 33554484
    invoke-virtual {v3}, Ljava/io/File;->exists()Z

    .line 33554485
    .line 33554486
    .line 33554487
    move-result v0

    .line 33554488
    if-eqz v0, :cond_1

    .line 33554489
    .line 33554490
    invoke-static {p0, v3}, LX/Cne;->LJIJJLI(ILjava/io/File;)Ljava/util/List;

    .line 33554491
    .line 33554492
    .line 33554493
    move-result-object v0

    .line 33554494
    invoke-virtual {v4, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554495
    .line 33554496
    .line 33554497
    :cond_1
    if-eqz p1, :cond_2

    .line 33554498
    .line 33554499
    invoke-static {p1}, LX/ccj;->LLLLIIL(Landroid/content/Context;)Ljava/io/File;

    .line 33554500
    .line 33554501
    .line 33554502
    move-result-object v3

    .line 33554503
    if-eqz v3, :cond_2

    .line 33554504
    .line 33554505
    invoke-virtual {v3}, Ljava/io/File;->exists()Z

    .line 33554506
    .line 33554507
    .line 33554508
    move-result v0

    .line 33554509
    if-eqz v0, :cond_2

    .line 33554510
    .line 33554511
    new-instance v2, Ljava/io/File;

    .line 33554512
    .line 33554513
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 33554514
    .line 33554515
    .line 33554516
    move-result-object v1

    .line 33554517
    invoke-virtual {v3}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 33554518
    .line 33554519
    .line 33554520
    move-result-object v0

    .line 33554521
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554522
    .line 33554523
    .line 33554524
    sget-object v0, Ljava/io/File;->separator:Ljava/lang/String;

    .line 33554525
    .line 33554526
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554527
    .line 33554528
    .line 33554529
    const-string v0, "music/rhythm"

    .line 33554530
    .line 33554531
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 33554532
    .line 33554533
    .line 33554534
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 33554535
    .line 33554536
    .line 33554537
    move-result-object v0

    .line 33554538
    invoke-direct {v2, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554539
    .line 33554540
    .line 33554541
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    .line 33554542
    .line 33554543
    .line 33554544
    move-result v0

    .line 33554545
    if-eqz v0, :cond_2

    .line 33554546
    .line 33554547
    invoke-static {p0, v2}, LX/Cne;->LJIJJLI(ILjava/io/File;)Ljava/util/List;

    .line 33554548
    .line 33554549
    .line 33554550
    move-result-object v0

    .line 33554551
    invoke-virtual {v4, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554552
    .line 33554553
    .line 33554554
    :cond_2
    invoke-static {}, LX/Cne;->LJIIL()Ljava/util/Set;

    .line 33554555
    .line 33554556
    .line 33554557
    move-result-object v3

    .line 33554558
    invoke-virtual {v4}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    .line 33554559
    .line 33554560
    .line 33554561
    move-result-object v2

    .line 33554562
    :cond_3
    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    .line 33554563
    .line 33554564
    .line 33554565
    move-result v0

    .line 33554566
    if-eqz v0, :cond_5

    .line 33554567
    .line 33554568
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    .line 33554569
    .line 33554570
    .line 33554571
    move-result-object v1

    .line 33554572
    check-cast v1, Ljava/io/File;

    .line 33554573
    .line 33554574
    if-eqz v1, :cond_4

    .line 33554575
    .line 33554576
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    .line 33554577
    .line 33554578
    .line 33554579
    move-result v0

    .line 33554580
    if-eqz v0, :cond_4

    .line 33554581
    .line 33554582
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 33554583
    .line 33554584
    .line 33554585
    move-result-object v1

    .line 33554586
    move-object v0, v3

    .line 33554587
    check-cast v0, Ljava/util/HashSet;

    .line 33554588
    .line 33554589
    invoke-virtual {v0, v1}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z

    .line 33554590
    .line 33554591
    .line 33554592
    move-result v0

    .line 33554593
    if-eqz v0, :cond_3

    .line 33554594
    .line 33554595
    :cond_4
    invoke-interface {v2}, Ljava/util/Iterator;->remove()V

    .line 33554596
    .line 33554597
    .line 33554598
    goto :goto_0

    .line 33554599
    :cond_5
    return-object v4
.end method

.method public static LJIIL()Ljava/util/Set;
    .locals 8
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/Set<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .prologue
    .line 0
    new-instance v4, Ljava/util/HashSet;

    .line 1
    .line 2
    invoke-direct {v4}, Ljava/util/HashSet;-><init>()V

    .line 3
    .line 4
    .line 5
    new-instance v7, Ljava/util/HashSet;

    .line 6
    .line 7
    invoke-direct {v7}, Ljava/util/HashSet;-><init>()V

    .line 8
    .line 9
    .line 10
    const/4 v5, 0x0

    .line 11
    :try_start_0
    invoke-static {}, Lcom/ss/android/ugc/aweme/out/AVExternalServiceImpl;->LIZ()Lcom/ss/android/ugc/aweme/services/IExternalService;

    .line 12
    .line 13
    .line 14
    move-result-object v0

    .line 15
    invoke-interface {v0}, Lcom/ss/android/ugc/aweme/services/IExternalService;->configService()Lcom/ss/android/ugc/aweme/services/external/IConfigService;

    .line 16
    .line 17
    .line 18
    move-result-object v0

    .line 19
    invoke-interface {v0}, Lcom/ss/android/ugc/aweme/services/external/IConfigService;->cacheConfig()Lcom/ss/android/ugc/aweme/services/external/ICacheService;

    .line 20
    .line 21
    .line 22
    move-result-object v6

    .line 23
    goto :goto_0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 24
    :catch_0
    move-object v6, v5

    .line 25
    :goto_0
    if-eqz v6, :cond_1

    .line 26
    .line 27
    invoke-static {}, LX/Bvj;->LJIIIIZZ()LX/Bvj;

    .line 28
    .line 29
    .line 30
    move-result-object v0

    .line 31
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 32
    .line 33
    .line 34
    const-string v3, "enable_setting_disk_manager"

    .line 35
    .line 36
    const/16 v0, 0x7c00

    .line 37
    .line 38
    const/4 v2, 0x0

    .line 39
    const/4 v1, 0x1

    .line 40
    invoke-static {v0, v2, v3, v1}, LX/Bvj;->LJIIIZ(IILjava/lang/String;Z)I

    .line 41
    .line 42
    .line 43
    move-result v0

    .line 44
    if-ne v0, v1, :cond_0

    .line 45
    .line 46
    const/4 v2, 0x1

    .line 47
    :cond_0
    if-eqz v2, :cond_5

    .line 48
    .line 49
    invoke-interface {v6}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->allowList()Ljava/util/Collection;

    .line 50
    .line 51
    .line 52
    move-result-object v0

    .line 53
    invoke-virtual {v7, v0}, Ljava/util/AbstractCollection;->addAll(Ljava/util/Collection;)Z

    .line 54
    .line 55
    .line 56
    :goto_1
    invoke-interface {v6}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->tempVideoFile()Ljava/util/Collection;

    .line 57
    .line 58
    .line 59
    move-result-object v0

    .line 60
    invoke-virtual {v7, v0}, Ljava/util/AbstractCollection;->addAll(Ljava/util/Collection;)Z

    .line 61
    .line 62
    .line 63
    invoke-interface {v6}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->originSoundFile()Ljava/util/Collection;

    .line 64
    .line 65
    .line 66
    move-result-object v0

    .line 67
    invoke-virtual {v7, v0}, Ljava/util/AbstractCollection;->addAll(Ljava/util/Collection;)Z

    .line 68
    .line 69
    .line 70
    invoke-interface {v6}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->mvRootDir()Ljava/lang/String;

    .line 71
    .line 72
    .line 73
    move-result-object v0

    .line 74
    invoke-virtual {v7, v0}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 75
    .line 76
    .line 77
    :cond_1
    invoke-virtual {v4, v7}, Ljava/util/AbstractCollection;->addAll(Ljava/util/Collection;)Z

    .line 78
    .line 79
    .line 80
    sget-object v0, LX/Cne;->LIZIZ:Ljava/lang/String;

    .line 81
    .line 82
    if-nez v0, :cond_2

    .line 83
    .line 84
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 85
    .line 86
    .line 87
    move-result-object v1

    .line 88
    invoke-static {}, LX/ccj;->G()Ljava/io/File;

    .line 89
    .line 90
    .line 91
    move-result-object v0

    .line 92
    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 93
    .line 94
    .line 95
    move-result-object v0

    .line 96
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 97
    .line 98
    .line 99
    const-string v0, "/DCIM/Camera/"

    .line 100
    .line 101
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 102
    .line 103
    .line 104
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 105
    .line 106
    .line 107
    move-result-object v0

    .line 108
    sput-object v0, LX/Cne;->LIZIZ:Ljava/lang/String;

    .line 109
    .line 110
    :cond_2
    new-instance v1, Ljava/io/File;

    .line 111
    .line 112
    sget-object v0, LX/Cne;->LIZIZ:Ljava/lang/String;

    .line 113
    .line 114
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 115
    .line 116
    .line 117
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    .line 118
    .line 119
    .line 120
    move-result-object v0

    .line 121
    invoke-virtual {v4, v0}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 122
    .line 123
    .line 124
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 125
    .line 126
    .line 127
    move-result-object v1

    .line 128
    invoke-static {}, LX/CP1;->LIZJ()Landroid/content/Context;

    .line 129
    .line 130
    .line 131
    move-result-object v0

    .line 132
    invoke-static {v0, v5}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 133
    .line 134
    .line 135
    move-result-object v0

    .line 136
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    .line 137
    .line 138
    .line 139
    const-string v0, "/splashad"

    .line 140
    .line 141
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 142
    .line 143
    .line 144
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 145
    .line 146
    .line 147
    move-result-object v0

    .line 148
    invoke-virtual {v4, v0}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 149
    .line 150
    .line 151
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 152
    .line 153
    .line 154
    move-result-object v2

    .line 155
    invoke-static {}, LX/CP1;->LIZJ()Landroid/content/Context;

    .line 156
    .line 157
    .line 158
    move-result-object v1

    .line 159
    invoke-static {}, Landroid/os/Environment;->isExternalStorageEmulated()Z

    .line 160
    .line 161
    .line 162
    move-result v0

    .line 163
    if-eqz v0, :cond_3

    .line 164
    .line 165
    invoke-static {v1}, LX/ccj;->LLLLIIL(Landroid/content/Context;)Ljava/io/File;

    .line 166
    .line 167
    .line 168
    move-result-object v0

    .line 169
    :goto_2
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 170
    .line 171
    .line 172
    move-result-object v0

    .line 173
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 174
    .line 175
    .line 176
    const-string v0, "/LiveWallpaper"

    .line 177
    .line 178
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 179
    .line 180
    .line 181
    invoke-static {v2}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 182
    .line 183
    .line 184
    move-result-object v0

    .line 185
    invoke-virtual {v4, v0}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z

    .line 186
    .line 187
    .line 188
    new-instance v0, LX/Cnf;

    .line 189
    .line 190
    invoke-direct {v0}, LX/Cnf;-><init>()V

    .line 191
    .line 192
    .line 193
    new-instance v2, LX/dXN;

    .line 194
    .line 195
    invoke-direct {v2, v4, v0}, LX/dXN;-><init>(Ljava/util/Collection;LX/dXK;)V

    .line 196
    .line 197
    .line 198
    new-instance v0, LX/Cng;

    .line 199
    .line 200
    invoke-direct {v0}, LX/Cng;-><init>()V

    .line 201
    .line 202
    .line 203
    new-instance v1, LX/dXN;

    .line 204
    .line 205
    invoke-direct {v1, v4, v0}, LX/dXN;-><init>(Ljava/util/Collection;LX/dXK;)V

    .line 206
    .line 207
    .line 208
    new-instance v0, Ljava/util/HashSet;

    .line 209
    .line 210
    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V

    .line 211
    .line 212
    .line 213
    invoke-virtual {v0, v4}, Ljava/util/AbstractCollection;->addAll(Ljava/util/Collection;)Z

    .line 214
    .line 215
    .line 216
    invoke-virtual {v0, v2}, Ljava/util/AbstractCollection;->addAll(Ljava/util/Collection;)Z

    .line 217
    .line 218
    .line 219
    invoke-virtual {v0, v1}, Ljava/util/AbstractCollection;->addAll(Ljava/util/Collection;)Z

    .line 220
    .line 221
    .line 222
    return-object v0

    .line 223
    :cond_3
    invoke-static {v1, v5}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 224
    .line 225
    .line 226
    move-result-object v0

    .line 227
    if-eqz v0, :cond_4

    .line 228
    .line 229
    invoke-static {v0}, LX/DG2;->LJ(Ljava/io/File;)V

    .line 230
    .line 231
    .line 232
    goto :goto_2

    .line 233
    :cond_4
    invoke-static {v1}, LX/ccj;->LLLLIIL(Landroid/content/Context;)Ljava/io/File;

    .line 234
    .line 235
    .line 236
    move-result-object v0

    .line 237
    goto :goto_2

    .line 238
    :cond_5
    invoke-interface {v6}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->draftAllowList()Ljava/util/Collection;

    .line 239
    .line 240
    .line 241
    move-result-object v0

    .line 242
    invoke-virtual {v7, v0}, Ljava/util/AbstractCollection;->addAll(Ljava/util/Collection;)Z

    .line 243
    .line 244
    .line 245
    goto/16 :goto_1
.end method

.method public static LJIILIIL()Ljava/io/File;
    .locals 3

    .prologue
    .line 0
    sget-object v0, LX/Cne;->LIZLLL:Ljava/io/File;

    .line 1
    .line 2
    if-eqz v0, :cond_0

    .line 3
    .line 4
    return-object v0

    .line 5
    :cond_0
    invoke-static {}, LX/CP1;->LIZJ()Landroid/content/Context;

    .line 6
    .line 7
    .line 8
    move-result-object v1

    .line 9
    sget-object v0, LX/D7F;->PREFER_SD_CARD:LX/D7F;

    .line 10
    .line 11
    invoke-static {v1, v0}, LX/D7B;->LJI(Landroid/content/Context;LX/D7F;)Ljava/io/File;

    .line 12
    .line 13
    .line 14
    move-result-object v2

    .line 15
    if-nez v2, :cond_1

    .line 16
    .line 17
    invoke-static {}, LX/DG2;->LJIIJJI()Ljava/io/File;

    .line 18
    .line 19
    .line 20
    move-result-object v0

    .line 21
    sput-object v0, LX/Cne;->LIZLLL:Ljava/io/File;

    .line 22
    .line 23
    return-object v0

    .line 24
    :cond_1
    new-instance v1, Ljava/io/File;

    .line 25
    .line 26
    const-string v0, "picture"

    .line 27
    .line 28
    invoke-direct {v1, v2, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 29
    .line 30
    .line 31
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    .line 32
    .line 33
    .line 34
    move-result v0

    .line 35
    if-nez v0, :cond_2

    .line 36
    .line 37
    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    .line 38
    .line 39
    .line 40
    :cond_2
    sput-object v1, LX/Cne;->LIZLLL:Ljava/io/File;

    .line 41
    .line 42
    return-object v1
.end method

.method public static LJIILJJIL(Landroid/content/Context;)Ljava/lang/String;
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
    sget-object v0, LX/Cne;->LIZJ:Ljava/lang/String;

    .line 16777222
    .line 16777223
    if-eqz v0, :cond_1

    .line 16777224
    .line 16777225
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    .line 16777226
    .line 16777227
    .line 16777228
    move-result v0

    .line 16777229
    if-nez v0, :cond_1

    .line 16777230
    .line 16777231
    sget-object v0, LX/Cne;->LIZJ:Ljava/lang/String;

    .line 16777232
    .line 16777233
    return-object v0

    .line 16777234
    :cond_1
    sget-object v0, LX/D7F;->PREFER_PRIVATE:LX/D7F;

    .line 16777235
    .line 16777236
    invoke-static {p0, v0}, LX/D7B;->LJII(Landroid/content/Context;LX/D7F;)Ljava/io/File;

    .line 16777237
    .line 16777238
    .line 16777239
    move-result-object v0

    .line 16777240
    if-eqz v0, :cond_2

    .line 16777241
    .line 16777242
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 16777243
    .line 16777244
    .line 16777245
    move-result-object v0

    .line 16777246
    :goto_0
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 16777247
    .line 16777248
    .line 16777249
    move-result-object v1

    .line 16777250
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777251
    .line 16777252
    .line 16777253
    const-string v0, "/share/"

    .line 16777254
    .line 16777255
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777256
    .line 16777257
    .line 16777258
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 16777259
    .line 16777260
    .line 16777261
    move-result-object v0

    .line 16777262
    sput-object v0, LX/Cne;->LIZJ:Ljava/lang/String;

    .line 16777263
    .line 16777264
    return-object v0

    .line 16777265
    :cond_2
    const/4 v1, 0x0

    .line 16777266
    invoke-static {p0, v1}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 16777267
    .line 16777268
    .line 16777269
    move-result-object v0

    .line 16777270
    if-nez v0, :cond_3

    .line 16777271
    .line 16777272
    invoke-static {}, LX/ccj;->G()Ljava/io/File;

    .line 16777273
    .line 16777274
    .line 16777275
    move-result-object v0

    .line 16777276
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 16777277
    .line 16777278
    .line 16777279
    move-result-object v0

    .line 16777280
    goto :goto_0

    .line 16777281
    :cond_3
    invoke-static {p0, v1}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 16777282
    .line 16777283
    .line 16777284
    move-result-object v0

    .line 16777285
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 16777286
    .line 16777287
    .line 16777288
    move-result-object v0

    .line 16777289
    goto :goto_0
.end method

.method public static LJIILL(Landroid/content/Context;)Ljava/lang/String;
    .locals 2

    .prologue
    .line 16777216
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 16777217
    .line 16777218
    .line 16777219
    move-result-object v1

    .line 16777220
    invoke-static {p0}, LX/Cne;->LJIILJJIL(Landroid/content/Context;)Ljava/lang/String;

    .line 16777221
    .line 16777222
    .line 16777223
    move-result-object v0

    .line 16777224
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777225
    .line 16777226
    .line 16777227
    const-string v0, "out"

    .line 16777228
    .line 16777229
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777230
    .line 16777231
    .line 16777232
    const-string v0, "/"

    .line 16777233
    .line 16777234
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777235
    .line 16777236
    .line 16777237
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 16777238
    .line 16777239
    .line 16777240
    move-result-object v0

    .line 16777241
    return-object v0
.end method

.method public static LJIILLIIL(Landroid/content/Context;)Ljava/lang/String;
    .locals 2

    .prologue
    .line 16777216
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 16777217
    .line 16777218
    .line 16777219
    move-result-object v1

    .line 16777220
    invoke-static {p0}, LX/Cne;->LJIILJJIL(Landroid/content/Context;)Ljava/lang/String;

    .line 16777221
    .line 16777222
    .line 16777223
    move-result-object v0

    .line 16777224
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777225
    .line 16777226
    .line 16777227
    const-string v0, "pic"

    .line 16777228
    .line 16777229
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777230
    .line 16777231
    .line 16777232
    const-string v0, "/"

    .line 16777233
    .line 16777234
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777235
    .line 16777236
    .line 16777237
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 16777238
    .line 16777239
    .line 16777240
    move-result-object v0

    .line 16777241
    return-object v0
.end method

.method public static LJIIZILJ(Landroid/content/Context;)Ljava/lang/String;
    .locals 3

    .prologue
    .line 16777216
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 16777217
    .line 16777218
    .line 16777219
    move-result-object v2

    .line 16777220
    if-nez p0, :cond_0

    .line 16777221
    .line 16777222
    const-string v0, ""

    .line 16777223
    .line 16777224
    :goto_0
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777225
    .line 16777226
    .line 16777227
    const-string v0, "tmp"

    .line 16777228
    .line 16777229
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777230
    .line 16777231
    .line 16777232
    const-string v0, "/"

    .line 16777233
    .line 16777234
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777235
    .line 16777236
    .line 16777237
    invoke-static {v2}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 16777238
    .line 16777239
    .line 16777240
    move-result-object v0

    .line 16777241
    return-object v0

    .line 16777242
    :cond_0
    invoke-static {p0}, LX/ccj;->LLLL(Landroid/content/Context;)Ljava/io/File;

    .line 16777243
    .line 16777244
    .line 16777245
    move-result-object v0

    .line 16777246
    const/4 v1, 0x0

    .line 16777247
    if-eqz v0, :cond_1

    .line 16777248
    .line 16777249
    invoke-virtual {v0}, Ljava/io/File;->getParentFile()Ljava/io/File;

    .line 16777250
    .line 16777251
    .line 16777252
    move-result-object v0

    .line 16777253
    if-eqz v0, :cond_1

    .line 16777254
    .line 16777255
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 16777256
    .line 16777257
    .line 16777258
    move-result-object v0

    .line 16777259
    :goto_1
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 16777260
    .line 16777261
    .line 16777262
    move-result-object v1

    .line 16777263
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777264
    .line 16777265
    .line 16777266
    const-string v0, "/share/"

    .line 16777267
    .line 16777268
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777269
    .line 16777270
    .line 16777271
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 16777272
    .line 16777273
    .line 16777274
    move-result-object v0

    .line 16777275
    goto :goto_0

    .line 16777276
    :cond_1
    invoke-static {p0, v1}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 16777277
    .line 16777278
    .line 16777279
    move-result-object v0

    .line 16777280
    if-nez v0, :cond_2

    .line 16777281
    .line 16777282
    invoke-static {}, LX/ccj;->G()Ljava/io/File;

    .line 16777283
    .line 16777284
    .line 16777285
    move-result-object v0

    .line 16777286
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 16777287
    .line 16777288
    .line 16777289
    move-result-object v0

    .line 16777290
    goto :goto_1

    .line 16777291
    :cond_2
    invoke-static {p0, v1}, LX/ccj;->LLLLIIIILLL(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;

    .line 16777292
    .line 16777293
    .line 16777294
    move-result-object v0

    .line 16777295
    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    .line 16777296
    .line 16777297
    .line 16777298
    move-result-object v0

    .line 16777299
    goto :goto_1
.end method

.method public static LJIJ(Landroid/content/Context;)Ljava/lang/String;
    .locals 2

    .prologue
    .line 16777216
    invoke-static {}, LX/CD7;->LIZ()Ljava/lang/StringBuilder;

    .line 16777217
    .line 16777218
    .line 16777219
    move-result-object v1

    .line 16777220
    invoke-static {p0}, LX/Cne;->LJIILJJIL(Landroid/content/Context;)Ljava/lang/String;

    .line 16777221
    .line 16777222
    .line 16777223
    move-result-object v0

    .line 16777224
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777225
    .line 16777226
    .line 16777227
    const-string v0, "tmp"

    .line 16777228
    .line 16777229
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777230
    .line 16777231
    .line 16777232
    const-string v0, "/"

    .line 16777233
    .line 16777234
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 16777235
    .line 16777236
    .line 16777237
    invoke-static {v1}, LX/CD7;->LIZIZ(Ljava/lang/StringBuilder;)Ljava/lang/String;

    .line 16777238
    .line 16777239
    .line 16777240
    move-result-object v0

    .line 16777241
    return-object v0
.end method

.method public static LJIJI(ILandroid/content/Context;)Ljava/util/List;
    .locals 3

    .prologue
    .line 33554432
    new-instance v2, Ljava/util/ArrayList;

    .line 33554433
    .line 33554434
    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    .line 33554435
    .line 33554436
    .line 33554437
    new-instance v1, Ljava/io/File;

    .line 33554438
    .line 33554439
    invoke-static {p1}, LX/Cne;->LJIILL(Landroid/content/Context;)Ljava/lang/String;

    .line 33554440
    .line 33554441
    .line 33554442
    move-result-object v0

    .line 33554443
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554444
    .line 33554445
    .line 33554446
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    .line 33554447
    .line 33554448
    .line 33554449
    move-result v0

    .line 33554450
    if-eqz v0, :cond_0

    .line 33554451
    .line 33554452
    invoke-static {p0, v1}, LX/Cne;->LJIJJLI(ILjava/io/File;)Ljava/util/List;

    .line 33554453
    .line 33554454
    .line 33554455
    move-result-object v0

    .line 33554456
    invoke-virtual {v2, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554457
    .line 33554458
    .line 33554459
    new-instance v1, Ljava/io/File;

    .line 33554460
    .line 33554461
    invoke-static {p1}, LX/Cne;->LJIJ(Landroid/content/Context;)Ljava/lang/String;

    .line 33554462
    .line 33554463
    .line 33554464
    move-result-object v0

    .line 33554465
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554466
    .line 33554467
    .line 33554468
    invoke-static {p0, v1}, LX/Cne;->LJIJJLI(ILjava/io/File;)Ljava/util/List;

    .line 33554469
    .line 33554470
    .line 33554471
    move-result-object v0

    .line 33554472
    invoke-virtual {v2, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554473
    .line 33554474
    .line 33554475
    new-instance v1, Ljava/io/File;

    .line 33554476
    .line 33554477
    invoke-static {p1}, LX/Cne;->LJIILLIIL(Landroid/content/Context;)Ljava/lang/String;

    .line 33554478
    .line 33554479
    .line 33554480
    move-result-object v0

    .line 33554481
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554482
    .line 33554483
    .line 33554484
    invoke-static {p0, v1}, LX/Cne;->LJIJJLI(ILjava/io/File;)Ljava/util/List;

    .line 33554485
    .line 33554486
    .line 33554487
    move-result-object v0

    .line 33554488
    invoke-virtual {v2, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554489
    .line 33554490
    .line 33554491
    :cond_0
    return-object v2
.end method

.method public static LJIJJ(ILjava/io/File;)Ljava/util/List;
    .locals 5

    .prologue
    .line 33554432
    invoke-virtual {p1}, Ljava/io/File;->exists()Z

    .line 33554433
    .line 33554434
    .line 33554435
    move-result v0

    .line 33554436
    if-eqz v0, :cond_6

    .line 33554437
    .line 33554438
    new-instance v3, Ljava/util/ArrayList;

    .line 33554439
    .line 33554440
    invoke-direct {v3}, Ljava/util/ArrayList;-><init>()V

    .line 33554441
    .line 33554442
    .line 33554443
    const/4 v4, 0x0

    .line 33554444
    :try_start_0
    invoke-static {}, Lcom/ss/android/ugc/aweme/out/AVExternalServiceImpl;->LIZ()Lcom/ss/android/ugc/aweme/services/IExternalService;

    .line 33554445
    .line 33554446
    .line 33554447
    move-result-object v0

    .line 33554448
    invoke-interface {v0}, Lcom/ss/android/ugc/aweme/services/IExternalService;->configService()Lcom/ss/android/ugc/aweme/services/external/IConfigService;

    .line 33554449
    .line 33554450
    .line 33554451
    move-result-object v0

    .line 33554452
    invoke-interface {v0}, Lcom/ss/android/ugc/aweme/services/external/IConfigService;->cacheConfig()Lcom/ss/android/ugc/aweme/services/external/ICacheService;

    .line 33554453
    .line 33554454
    .line 33554455
    move-result-object v2

    .line 33554456
    goto :goto_0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 33554457
    :catchall_0
    move-object v2, v4

    .line 33554458
    :goto_0
    if-nez v2, :cond_0

    .line 33554459
    .line 33554460
    sget-object v0, Ljava/util/Collections;->EMPTY_LIST:Ljava/util/List;

    .line 33554461
    .line 33554462
    return-object v0

    .line 33554463
    :cond_0
    :try_start_1
    invoke-interface {v2}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->rawVideoFile()[Ljava/io/File;

    .line 33554464
    .line 33554465
    .line 33554466
    move-result-object v1

    .line 33554467
    goto :goto_1
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    .line 33554468
    :catch_0
    move-object v1, v4

    .line 33554469
    :goto_1
    if-eqz v1, :cond_1

    .line 33554470
    .line 33554471
    mul-int/lit8 v0, p0, 0x2

    .line 33554472
    .line 33554473
    invoke-static {v1, v0}, LX/Cne;->LJIL([Ljava/io/File;I)Ljava/util/List;

    .line 33554474
    .line 33554475
    .line 33554476
    move-result-object v0

    .line 33554477
    if-eqz v0, :cond_1

    .line 33554478
    .line 33554479
    invoke-virtual {v3, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554480
    .line 33554481
    .line 33554482
    :cond_1
    :try_start_2
    invoke-interface {v2}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->voiceFile()[Ljava/io/File;

    .line 33554483
    .line 33554484
    .line 33554485
    move-result-object v0

    .line 33554486
    goto :goto_2
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1

    .line 33554487
    :catch_1
    move-object v0, v4

    .line 33554488
    :goto_2
    invoke-static {v0, p0}, LX/Cne;->LJIL([Ljava/io/File;I)Ljava/util/List;

    .line 33554489
    .line 33554490
    .line 33554491
    move-result-object v0

    .line 33554492
    if-eqz v0, :cond_2

    .line 33554493
    .line 33554494
    invoke-virtual {v3, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554495
    .line 33554496
    .line 33554497
    :cond_2
    :try_start_3
    invoke-interface {v2}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->outputFile()[Ljava/io/File;

    .line 33554498
    .line 33554499
    .line 33554500
    move-result-object v0

    .line 33554501
    goto :goto_3
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_2

    .line 33554502
    :catch_2
    move-object v0, v4

    .line 33554503
    :goto_3
    invoke-static {v0, p0}, LX/Cne;->LJIL([Ljava/io/File;I)Ljava/util/List;

    .line 33554504
    .line 33554505
    .line 33554506
    move-result-object v0

    .line 33554507
    if-eqz v0, :cond_3

    .line 33554508
    .line 33554509
    invoke-virtual {v3, v0}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554510
    .line 33554511
    .line 33554512
    :cond_3
    :try_start_4
    invoke-interface {v2}, Lcom/ss/android/ugc/aweme/services/external/ICacheService;->synthesisFile()[Ljava/io/File;

    .line 33554513
    .line 33554514
    .line 33554515
    move-result-object v4
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_3

    .line 33554516
    :catch_3
    invoke-static {v4, p0}, LX/Cne;->LJIL([Ljava/io/File;I)Ljava/util/List;

    .line 33554517
    .line 33554518
    .line 33554519
    move-result-object v2

    .line 33554520
    if-eqz v2, :cond_4

    .line 33554521
    .line 33554522
    invoke-virtual {v3, v2}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554523
    .line 33554524
    .line 33554525
    :cond_4
    new-instance v1, Ljava/io/File;

    .line 33554526
    .line 33554527
    sget-object v0, LX/Cni;->LIZIZ:LX/Cni;

    .line 33554528
    .line 33554529
    invoke-virtual {v0}, LX/Cni;->getDownloadDir()Ljava/lang/String;

    .line 33554530
    .line 33554531
    .line 33554532
    move-result-object v0

    .line 33554533
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 33554534
    .line 33554535
    .line 33554536
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    .line 33554537
    .line 33554538
    .line 33554539
    move-result v0

    .line 33554540
    if-eqz v0, :cond_5

    .line 33554541
    .line 33554542
    mul-int/lit8 v0, p0, 0x2

    .line 33554543
    .line 33554544
    invoke-static {v0, v1}, LX/Cne;->LJIJJLI(ILjava/io/File;)Ljava/util/List;

    .line 33554545
    .line 33554546
    .line 33554547
    move-result-object v0

    .line 33554548
    if-eqz v0, :cond_5

    .line 33554549
    .line 33554550
    invoke-virtual {v3, v2}, Ljava/util/ArrayList;->addAll(Ljava/util/Collection;)Z

    .line 33554551
    .line 33554552
    .line 33554553
    :cond_5
    return-object v3

    .line 33554554
    :cond_6
    sget-object v0, Ljava/util/Collections;->EMPTY_LIST:Ljava/util/List;

    .line 33554555
    .line 33554556
    return-object v0
.end method

.method public static LJIJJLI(ILjava/io/File;)Ljava/util/List;
    .locals 3

    .prologue
    .line 33554432
    invoke-virtual {p1}, Ljava/io/File;->exists()Z

    .line 33554433
    .line 33554434
    .line 33554435
    move-result v0

    .line 33554436
    if-eqz v0, :cond_0

    .line 33554437
    .line 33554438
    invoke-virtual {p1}, Ljava/io/File;->listFiles()[Ljava/io/File;

    .line 33554439
    .line 33554440
    .line 33554441
    move-result-object v1

    .line 33554442
    if-eqz v1, :cond_0

    .line 33554443
    .line 33554444
    array-length v0, v1

    .line 33554445
    if-lez v0, :cond_0

    .line 33554446
    .line 33554447
    invoke-static {v1}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;

    .line 33554448
    .line 33554449
    .line 33554450
    move-result-object v2

    .line 33554451
    new-instance v1, LY/AComparatorS14S0000000_5;

    .line 33554452
    .line 33554453
    const/4 v0, 0x4

    .line 33554454
    invoke-direct {v1, v0}, LY/AComparatorS14S0000000_5;-><init>(I)V

    .line 33554455
    .line 33554456
    .line 33554457
    invoke-static {v2, v1}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 33554458
    .line 33554459
    .line 33554460
    invoke-interface {v2}, Ljava/util/List;->size()I

    .line 33554461
    .line 33554462
    .line 33554463
    move-result v0

    .line 33554464
    if-le v0, p0, :cond_0

    .line 33554465
    .line 33554466
    invoke-interface {v2}, Ljava/util/List;->size()I

    .line 33554467
    .line 33554468
    .line 33554469
    move-result v1

    .line 33554470
    sub-int/2addr v1, p0

    .line 33554471
    const/4 v0, 0x0

    .line 33554472
    invoke-interface {v2, v0, v1}, Ljava/util/List;->subList(II)Ljava/util/List;

    .line 33554473
    .line 33554474
    .line 33554475
    move-result-object v0

    .line 33554476
    return-object v0

    .line 33554477
    :cond_0
    sget-object v0, Ljava/util/Collections;->EMPTY_LIST:Ljava/util/List;

    .line 33554478
    .line 33554479
    return-object v0
.end method

.method public static LJIL([Ljava/io/File;I)Ljava/util/List;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "([",
            "Ljava/io/File;",
            "I)",
            "Ljava/util/List<",
            "Ljava/io/File;",
            ">;"
        }
    .end annotation

    .prologue
    .line 33554432
    if-eqz p0, :cond_0

    .line 33554433
    .line 33554434
    array-length v0, p0

    .line 33554435
    if-lez v0, :cond_0

    .line 33554436
    .line 33554437
    invoke-static {p0}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;

    .line 33554438
    .line 33554439
    .line 33554440
    move-result-object p0

    .line 33554441
    new-instance v1, LY/AComparatorS14S0000000_5;

    .line 33554442
    .line 33554443
    const/4 v0, 0x3

    .line 33554444
    invoke-direct {v1, v0}, LY/AComparatorS14S0000000_5;-><init>(I)V

    .line 33554445
    .line 33554446
    .line 33554447
    invoke-static {p0, v1}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 33554448
    .line 33554449
    .line 33554450
    invoke-interface {p0}, Ljava/util/List;->size()I

    .line 33554451
    .line 33554452
    .line 33554453
    move-result v0

    .line 33554454
    if-le v0, p1, :cond_0

    .line 33554455
    .line 33554456
    invoke-interface {p0}, Ljava/util/List;->size()I

    .line 33554457
    .line 33554458
    .line 33554459
    move-result v1

    .line 33554460
    sub-int/2addr v1, p1

    .line 33554461
    const/4 v0, 0x0

    .line 33554462
    invoke-interface {p0, v0, v1}, Ljava/util/List;->subList(II)Ljava/util/List;

    .line 33554463
    .line 33554464
    .line 33554465
    move-result-object v0

    .line 33554466
    return-object v0

    .line 33554467
    :cond_0
    sget-object v0, Ljava/util/Collections;->EMPTY_LIST:Ljava/util/List;

    .line 33554468
    .line 33554469
    return-object v0
.end method

.method public static LJJ(ILjava/io/File;)V
    .locals 2

    .prologue
    .line 33554432
    new-instance v1, Ljava/io/File;

    .line 33554433
    .line 33554434
    const-string v0, "out"

    .line 33554435
    .line 33554436
    invoke-direct {v1, p1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 33554437
    .line 33554438
    .line 33554439
    invoke-static {p0, v1}, LX/Cne;->LJIJJLI(ILjava/io/File;)Ljava/util/List;

    .line 33554440
    .line 33554441
    .line 33554442
    move-result-object v0

    .line 33554443
    invoke-static {v0}, LX/Cne;->LIZLLL(Ljava/util/List;)V

    .line 33554444
    .line 33554445
    .line 33554446
    new-instance v1, Ljava/io/File;

    .line 33554447
    .line 33554448
    const-string v0, "tmp"

    .line 33554449
    .line 33554450
    invoke-direct {v1, p1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 33554451
    .line 33554452
    .line 33554453
    invoke-static {p0, v1}, LX/Cne;->LJIJJLI(ILjava/io/File;)Ljava/util/List;

    .line 33554454
    .line 33554455
    .line 33554456
    move-result-object v0

    .line 33554457
    invoke-static {v0}, LX/Cne;->LIZLLL(Ljava/util/List;)V

    .line 33554458
    .line 33554459
    .line 33554460
    new-instance v1, Ljava/io/File;

    .line 33554461
    .line 33554462
    const-string v0, "pic"

    .line 33554463
    .line 33554464
    invoke-direct {v1, p1, v0}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 33554465
    .line 33554466
    .line 33554467
    invoke-static {p0, v1}, LX/Cne;->LJIJJLI(ILjava/io/File;)Ljava/util/List;

    .line 33554468
    .line 33554469
    .line 33554470
    move-result-object v0

    .line 33554471
    invoke-static {v0}, LX/Cne;->LIZLLL(Ljava/util/List;)V

    .line 33554472
    .line 33554473
    .line 33554474
    return-void
.end method
