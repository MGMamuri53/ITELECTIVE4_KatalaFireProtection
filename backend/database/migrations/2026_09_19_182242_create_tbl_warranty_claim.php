<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_warrantyClaim', function (Blueprint $table) {
            $table->bigIncrements('v_warrantyClaimId');

            $table->unsignedBigInteger('v_warrantyId');

            $table->string('v_claimNumber', 60)
                ->nullable()
                ->unique();

            $table->dateTime('v_claimDate')
                ->useCurrent();

            $table->text('v_concernDescription');

            $table->string('v_claimStatus', 50)
                ->nullable();

            $table->text('v_resolutionDetails')
                ->nullable();

            $table->dateTime('v_resolvedDate')
                ->nullable();

            $table->text('v_notes')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            $table->foreign(
                'v_warrantyId',
                'fk_warrantyClaim_warranty'
            )
                ->references('v_warrantyId')
                ->on('tbl_warranty')
                ->onUpdate('cascade')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_warrantyClaim');
    }
};