cdef class ContentStorage(AAFObject):
    """
    This object has all Mobs and Essence Data in the file
    """
    def __cinit__(self):
        self.iid = lib.IID_IAAFContentStorage
        self.auid = lib.AUID_AAFContentStorage
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFContentStorage)

        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def count_mobs(self):
        """
        Total number of mobs in AAF File

        :returns: int
        """
        cdef lib.aafUInt32 mobCount
        error_check(self.ptr.CountMobs(lib.kAAFAllMob, &mobCount))
        return mobCount

    def add_mob(self, Mob mob not None):
        """add_mob(mob)

        Add a :class:`aaf.mob.Mob` object to ContentStorage

        :param aaf.mob.Mob mob: Mob object to add.
        """
        error_check(self.ptr.AddMob(mob.ptr))

    def remove_mob(self, Mob mob not None):
        """remove_mob(mob)

        Remove a :class:`aaf.mob.Mob` object from ContentStorage.

        :param aaf.mob.Mob mob: Mob object to remove.
        """

        error_check(self.ptr.RemoveMob(mob.ptr))

    def lookup_mob(self, mobID):
        """lookup_mob(mobID)

        Looks up the Mob that matches the given mob id.

        :param mobID: 9d of :class:`aaf.mob.Mob` to lookup.
        :type mobID: :class:`aaf.util.MobID` or :class:`str`
        :returns: :class:`aaf.mob.Mob`
        """

        cdef Mob mob = Mob.__new__(Mob)
        cdef MobID mobID_obj = MobID(mobID)

        error_check(self.ptr.LookupMob(mobID_obj.mobID, &mob.ptr))
        mob.query_interface()
        mob.root = self.root
        return mob.resolve()


    def mobs(self):
        """
        Returns a :class:`aaf.iterator.MobIter`` that iterates over all :class:`aaf.mob.Mob` objects in the AAF file.

        :returns: :class:`aaf.iterator.MobIter`
        """

        cdef MobIter mob_iter = MobIter.__new__(MobIter)

        cdef lib.aafSearchCrit_t search_crit

        search_crit.searchTag = lib.kAAFByMobKind
        search_crit.tags.mobKind = lib.kAAFAllMob

        error_check(self.ptr.GetMobs(&search_crit, &mob_iter.ptr))
        mob_iter._clone_iter = self.mobs
        mob_iter.root = self.root
        return mob_iter

    def master_mobs(self):
        """
        Returns a :class:`aaf.iterator.MobIter` that iterates over all :class:`aaf.mob.MasterMob` objects in the AAF file.

        :returns: :class:`aaf.iterator.MobIter`
        """

        cdef MobIter mob_iter = MobIter.__new__(MobIter)

        cdef lib.aafSearchCrit_t search_crit

        search_crit.searchTag = lib.kAAFByMobKind
        search_crit.tags.mobKind = lib.kAAFMasterMob

        error_check(self.ptr.GetMobs(&search_crit, &mob_iter.ptr))
        mob_iter._clone_iter = self.master_mobs
        mob_iter.root = self.root
        return mob_iter

    def composition_mobs(self):
        """
        Returns a :class:`aaf.iterator.MobIter` that iterates over all :class:`aaf.mob.CompositionMob` objects in the AAF file.

        :returns: :class:`aaf.iterator.MobIter`
        """

        cdef MobIter mob_iter = MobIter.__new__(MobIter)

        cdef lib.aafSearchCrit_t search_crit

        search_crit.searchTag = lib.kAAFByMobKind
        search_crit.tags.mobKind = lib.kAAFCompMob

        error_check(self.ptr.GetMobs(&search_crit, &mob_iter.ptr))
        mob_iter._clone_iter = self.composition_mobs
        mob_iter.root = self.root
        return mob_iter

    def toplevel_mobs(self):
        """
        Returns a :class:`aaf.iterator.MobIter` that iterates over all :class:`aaf.mob.CompositionMob`
        objects in the AAF file with ``"UsageType""`` property set to ``"Usage_TopLevel"``.

        :returns: :class:`aaf.iterator.MobIter`
        """
        cdef MobIter mob_iter = MobIter.__new__(MobIter)

        cdef lib.aafSearchCrit_t search_crit

        search_crit.searchTag = lib.kAAFByCompositionMobUsageCode
        search_crit.tags.usageCode = lib.kAAFUsage_TopLevel

        error_check(self.ptr.GetMobs(&search_crit, &mob_iter.ptr))
        mob_iter._clone_iter = self.toplevel_mobs
        mob_iter.root = self.root
        return mob_iter

    def essence_data(self):
        """
        Returns a :class:`aaf.iterator.EssenceDataIter` that iterates over all
        embedded :class:`aaf.essence.EssenceData` in AAF file.

        :returns: :class:`aaf.iterator.EssenceDataIter`
        """

        cdef EssenceDataIter data_iter = EssenceDataIter.__new__(EssenceDataIter)
        error_check(self.ptr.EnumEssenceData(&data_iter.ptr))
        data_iter.root = self.root
        return data_iter

    def add_essence_data(self, EssenceData data not None):
        error_check(self.ptr.AddEssenceData(data.ptr))

    def remove_essence_data(self, EssenceData data not None):
        error_check(self.ptr.RemoveEssenceData(data.ptr))
